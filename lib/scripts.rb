# frozen_string_literal: true

require 'csv'

module Scripts

  def self.run_import(csv_path)
    Import.new(csv_path).run!
  end

  class Import
    ERROR_FILE_OUTPUT_PATH=Rails.root.join('tmp', 'import_errors.json').to_s

    CURATOR_COLLECTION_CLASSES=['Bplmodels::Collection', 'Bplmodels::SystemCollection', 'Bplmodels::OAICollection'].freeze

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
    end

    def run!
      row_count = import_rows.count
      Ark.connection_pool.with_connection do
        import_rows.each_with_index do |row, i|
          puts "Row is #{i + 1}/#{row_count}"
          begin
            row[:local_original_identifier_type] = normalize_local_original_identifier_type(row[:local_original_identifier_type])

            Ark.create_or_find_by!(row.slice(:namespace_id, :noid, :local_original_identifier, :local_original_identifier_type, :pid, :parent_pid)) do |ark|
              ark.created_at = row[:created_at]
              ark.namespace_ark = row[:namespace_ark]
              ark.url_base = ENV.fetch('ARK_MANAGER_DEFAULT_BASE_URL', 'https://search-dc3dev.bpl.org')
              ark.model_type = dc3_class_translation(row[:model_type])
              ark.deleted = row[:deleted] || false
              ark.secondary_parent_pids = normalize_secondary_parent_pids(row[:secondary_parent_pids])
            end
          rescue StandardError => e
            puts "Error Occured on Row #{i + 1}"
            puts "Reason #{e.message}"
            add_error_row!(row, e)
            next
          end
        end
      end
    ensure
      output_errors_as_json
    end

    protected

    def parse_csv_rows!
      parsed_rows = []

      CSV.foreach(csv_path, headers: true, header_converters: :symbol) do |row|
        parsed_rows << row.to_h.except(:id, :updated_at, :view_thumbnail, :view_object)
      end
      parsed_rows
    end

    private

    def add_error_row!(row, error)
      import_errors << {
        row: row,
        error: {
          kind: error.class.name,
          msg: error.message
        }
      }
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
