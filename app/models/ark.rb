# frozen_string_literal: true

class Ark < ApplicationRecord
  LOCAL_ID_TYPES = [
    'physical_location',
    'institution_collection_name',
    'institution_name',
    'barcode',
    'filename',
    'marc_md5',
    'id_local-accession',
    'id_local-other',
    'dspace_handle',
    'oai_header_id'
  ].freeze

  extend FriendlyId

  default_scope { order(created_at: :desc) }

  friendly_id :slug_candidates

  scope :active, -> { where(deleted: false) }

  scope :with_parent, ->(parent_pid) { where.not(parent_pid: nil).where(parent_pid: parent_pid) }

  scope :without_parent, -> { where(parent_pid: nil) }

  scope :with_model_type, ->(model_type) { where(model_type: model_type) }

  scope :with_local_id, ->(identifier, identifier_type) { where(local_original_identifier: identifier, local_original_identifier_type: identifier_type) }

  scope :without_parent_and_with_local_id_and_model_type, ->(identifier, identifier_type, model_type) { without_parent.with_local_id(identifier, identifier_type).with_model_type(model_type) }

  scope :with_parent_and_local_id_and_model_type, ->(parent_pid, identifier, identifier_type, model_type) { with_parent(parent_pid).with_local_id(identifier, identifier_type).with_model_type(model_type) }

  scope :object_in_view, ->(namespace_ark, noid) { active.merge(where(namespace_ark: namespace_ark, noid: noid)) }

  scope :minter_exists_scope, -> { unscoped.select(:noid).order(noid: :desc) }

  scope :noid_cache_scope, -> {  unscoped.select('DISTINCT ON (noid) noid, id, updated_at') }

  # NOTE: Need to add this to the callback list due to firendly id also using a before validation
  before_validation :set_noid, on: :create, prepend: true

  validates :namespace_ark,
            :namespace_id,
            :model_type,
            :local_original_identifier,
            presence: true

  validates :local_original_identifier_type, presence: true, inclusion: { in: LOCAL_ID_TYPES }
  validates :local_original_identifier, uniqueness: { scope: [:local_original_identifier_type, :model_type] }, if: proc { |a| a.parent_pid.blank? }
  validates :local_original_identifier, uniqueness: { scope: [:local_original_identifier_type, :model_type, :parent_pid] }, if: proc { |a| a.parent_pid.present? }
  validates :noid, presence: true, uniqueness: { case_sensitive: false }
  validates :url_base, presence: true, format: { with: URI.regexp(['http', 'https']) }

  # NOTE: Decided to keep this but renamed the method. Maybe useful for debugging/ future
  def self.noid_cache
    current_noids = []
    Rails.cache.fetch([noid_cache_scope, 'current_noids'], expires_in: 12.hours, race_condition_ttl: 10.seconds, skip_nil: true) do
      noid_cache_scope.in_batches(of: 100_000) do |noid_batch|
        Rails.cache.fetch([noid_batch, 'noids'], expires_in: 8.hours, race_condition_ttl: 10.seconds, skip_nil: true, force: true) do
          current_noids += noid_batch.pluck(:noid)
        end
      end
    end
    current_noids
  end

  def self.identifier_in_use?(noid)
    Rails.cache.fetch([noid, 'identifier_in_use'], expires_in: 2.days, race_condition_ttl: 10.seconds, skip_nil: true) do
      minter_exists_scope.exists?(noid: noid) ? true : nil
    end.present?
  end

  def to_s
    Oj.dump(as_json, indent: 2)
  end

  # NOTE:  method needed for friendly id
  def slug_candidates
    [
      [:namespace_id, :noid]
    ]
  end

  def redirect_url
    "#{url_base}/search/#{pid}"
  end

  private

  def set_noid
    return unless namespace_id.present? && noid.blank?

    minter_service = MinterService.call(namespace_id)
    return self.noid = minter_service.result if minter_service.successful?

    Rails.logger.error 'Failed to mint noid for ark!'
    Rails.logger.error "Reasons Given #{minter_service.errors.full_messages.join('\n')}"
  end
end
