# frozen_string_literal: true

class Ark < ApplicationRecord
  extend FriendlyId

  default_scope { order(created_at: :desc) }

  friendly_id :slug_candidates, sequence_separator: ':'

  scope :active, -> { where(deleted: false) }
  scope :by_parent, ->(parent_id) { where(parent_id: parent_pid) }
  scope :by_local_id, ->(identifier, identifier_type) { where(local_original_identifier: identifier, local_original_identifier_type: identifier_type) }
  scope :with_namespace_ark, ->(namespace_ark) { where(namespace_ark: namespace_ark) }

  # NOTE: Need to add this to the callback list due to firendly id also using a before validation
  before_validation :set_noid, on: :create, prepend: true

  validates :namespace_ark,
            :namespace_id,
            :model_type,
            :local_original_identifier,
            :local_original_identifier_type,
            presence: true

  validates :noid, presence: true, uniqueness: true
  validates :url_base, presence: true, format: { with: URI.regexp(['http', 'https']) }

  def to_s
    JSON.pretty_generate(as_json)
  end

  # NOTE:  method needed for friendly id
  def slug_candidates
    [
      [:namespace_id, :noid]
    ]
  end

  def redirect_base_url
    "#{url_base}/search/#{pid}"
  end

  private

  def set_noid
    self.noid = MinterService.call(namespace_id)
  end
end
