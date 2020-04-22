# frozen_string_literal: true

class Ark < ApplicationRecord
  LOCAL_ID_TYPES = ['Physical Location', 'Institution Collection Name', 'Barcode', 'filename', 'id_local-accession field', 'DSpace Handle', 'id_local-other field'].freeze

  extend FriendlyId

  default_scope { order(created_at: :desc) }

  friendly_id :slug_candidates

  scope :active, -> { where(deleted: false) }

  scope :with_parent, ->(parent_pid) { where(parent_pid: parent_pid) }

  scope :with_local_id, ->(identifier, identifier_type) { where(local_original_identifier: identifier, local_original_identifier_type: identifier_type) }

  scope :with_parent_and_local_id, ->(parent_pid, identifier, identifier_type) { with_parent(parent_pid).merge(with_local_id(identifier, identifier_type)) }

  scope :object_in_view, ->(namespace_ark, noid) { active.merge(where(namespace_ark: namespace_ark, noid: noid)) }

  # NOTE: Need to add this to the callback list due to firendly id also using a before validation
  before_validation :set_noid, on: :create, prepend: true

  validates :namespace_ark,
            :namespace_id,
            :model_type,
            :local_original_identifier,
            presence: true

  validates :local_original_identifier_type, presence: true, inclusion: { in: LOCAL_ID_TYPES }
  validates :noid, presence: true, uniqueness: { case_sensitive: false }
  validates :url_base, presence: true, format: { with: URI.regexp(['http', 'https']) }

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
    if minter_service.successful?
      self.noid = minter_service.result
    else
      Rails.logger.error 'Failed to mint noid for ark!'
      Rails.logger.error "Reasons Given #{minter_service.errors.full_messages.join('\n')}"
    end
  end
end
