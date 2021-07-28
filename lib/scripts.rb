# frozen_string_literal: true

require 'csv'
require 'monitor'

module Scripts

  def self.run_import(csv_path)
    Import.new(csv_path).run!
  end

  class Import
    ERROR_FILE_OUTPUT_PATH=Rails.root.join('tmp', 'import_errors.json').to_s

    CURATOR_COLLECTION_CLASSES=['Bplmodels::Collection', 'Bplmodels::SystemCollection', 'Bplmodels::OAICollection'].freeze

    ARK_BASE_URL=ENV.fetch('ARK_MANAGER_DEFAULT_BASE_URL') { Rails.application.credentials.dig(:ark, :base_url) || raise('No Value present for base Ark Url') }.freeze

    BATCH_SIZE=ENV.fetch('RAILS_MAX_THREADS') { 5 }

    CURATOR_DIGITAL_OBJECT_CLASSES=[
      'Bplmodels::Object',
      'Bplmodels::ObjectBase',
      'Bplmodels::OAIObject',
      'Bplmodels::Book',
      'Bplmodels::Card',
      'Bplmodels::Correspondence',
      'Bplmodels::Document',
      'Bplmodels::Ephemera',
      'Bplmodels::Manuscript',
      'Bplmodels::Map',
      'Bplmodels::MovingImage',
      'Bplmodels::MusicalNotation',
      'Bplmodels::Newspaper',
      'Bplmodels::NonPhotographicPrint',
      'Bplmodels::Periodical',
      'Bplmodels::PhotographicPrint',
      'Bplmodels::Scrapbook',
      'Bplmodels::SoundRecording'
    ].freeze

    attr_reader :csv_path,:import_rows ,:import_errors

    def initialize(csv_path)
      @csv_path = csv_path
      @import_rows = parse_csv_rows!
      @import_errors = []
      @import_errors.extend(MonitorMixin)
    end

    def run!
      row_count = import_rows.count
      batch_count = row_count / BATCH_SIZE
      puts "Total row count is #{row_count}"
      puts "Total No of batches #{batch_count}"
      import_rows.each_slice(BATCH_SIZE).with_index do |ark_batch, batch_i|
        puts "batch is #{batch_i + 1 }/#{batch_count}"
        process_batch(ark_batch)
        puts "Succefully imported batch! #{batch_i + 1 }/#{batch_count}"
      end
    ensure
      output_errors_as_json
    end

    protected

    def process_batch(ark_batch)
      threads = ark_batch.map do |ark_row|
        Thread.new do
          Rails.application.executor.wrap do
            Thread.current.abort_on_exception = true
            Ark.connection_pool.with_connection do
              import_row(ark_row)
            end
          end
        end
      end
      ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
        threads.each(&:join)
      end
    end


    def parse_csv_rows!
      parsed_rows = []

      CSV.foreach(csv_path, headers: true, header_converters: :symbol) do |row|
        parsed_rows << row.to_h.except(:id, :updated_at, :view_thumbnail, :view_object)
      end
      parsed_rows
    end

    private

    def import_row(ark_row)
      begin
        Ark.transaction(requires_new: true) do
          Ark.find_or_create_by!(ark_row.slice(:namespace_id, :noid, :local_original_identifier, :pid, :parent_pid)) do |ark|
            ark.local_original_identifier_type = normalize_local_original_identifier_type(ark_row[:local_original_identifier_type])
            ark.created_at = ark_row[:created_at]
            ark.namespace_ark = ark_row[:namespace_ark]
            ark.url_base = ARK_BASE_URL
            ark.model_type = dc3_class_translation(ark_row[:model_type])
            ark.deleted = ark_row[:deleted] || false
            ark.secondary_parent_pids = normalize_secondary_parent_pids(ark_row[:secondary_parent_pids])
          end
        end
      rescue StandardError => e
        puts "Error Occured on Row #{ark_row.inspect}"
        puts "Reason #{e.message}"
        add_error_row!(ark_row, e)
      end
    end

    def add_error_row!(ark_row, error)
      import_errors.synchronize do
        import_errors << {
          row: ark_row,
          error: {
            kind: error.class.name,
            msg: error.message
          }
        }
      end
    end

    def dc3_class_translation(old_model_type)
      case old_model_type
      when 'Bplmodels::Institution'
        'Curator::Institution'
      when 'Bplmodels::AudioFile'
        'Curator::Filestreams::Audio'
      when 'Bplmodels::DocumentFile'
        'Curator::Filestreams::Document'
      when 'Bplmodels::EreaderFile'
        'Curator::Filestreams::Ereader'
      when 'Bplmodels::ImageFile'
        'Curator::Filestreams::Image'
      when 'Bplmodels::VideoFile'
        'Curator::Filestreams::Video'
      when *CURATOR_COLLECTION_CLASSES
        'Curator::Collection'
      when *CURATOR_DIGITAL_OBJECT_CLASSES
        'Curator::DigitalObject'
      else
        raise ArgumentError, "Unknown Class #{old_model_type}"
      end
    end

    def normalize_local_original_identifier_type(local_original_identifier_type)
      case local_original_identifier_type
      when 'Physical Location'
        'physical_location'
      when 'Institution Collection Name'
        'institution_collection_name'
      when 'DSpace Handle'
        'dspace_handle'
      when 'id_local-accession field'
        'id_local-accession'
      when 'id_local-other field'
        'id_local-other'
      when 'Institution Name'
        'institution_name'
      when 'OAI Header Identifier'
        'oai_header_id'
      when 'Barcode'
        'barcode'
      when 'Marc MD5'
        'marc_md5'
      when 'filename', 'File Name', 'Filename'
        'filename'
      else
        raise ArgumentError, "Unknown local_original_identifier_type #{local_original_identifier_type}"
      end
    end

    # NOTE Due to string values present such as "{bpl-dev:w9506g03s,bpl-dev:w9506g042}" I Created a normalization method
    def normalize_secondary_parent_pids(secondary_parent_pids)
      return [] if secondary_parent_pids == '{}'
      secondary_parent_pids.tr('{', '').tr('[', '').tr('}', '').tr(']', '').split(',')
    end

    def output_errors_as_json
      return if import_errors.blank?

      File.open(ERROR_FILE_OUTPUT_PATH, 'w+') do |f|
        f.write(Oj.dump(import_errors.as_json, indent: 3))
      end
    end
  end
end
