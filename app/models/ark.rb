# frozen_string_literal: true

class Ark < ApplicationRecord
  extend FriendlyId

  default_scope { order(created_at: :desc) }

  friendly_id :slug_candidates, sequence_separator: ':'

  scope :active, -> { where(deleted: false) }

  scope :with_parent, ->(parent_pid) { where(parent_pid: parent_pid) }

  scope :with_local_id, ->(identifier, identifier_type) { where(local_original_identifier: identifier,
  local_original_identifier_type: identifier_type) }

  scope :with_parent_and_local_id, ->(parent_pid, identifier, identifier_type) { with_parent(parent_pid).merge(with_local_id(identifier, identifier_type)) }

  scope :object_in_view, ->(namespace_ark, noid) { active.merge(where(namespace_ark: namespace_ark, noid: noid)) }

  # NOTE: Need to add this to the callback list due to firendly id also using a before validation
  before_validation :set_noid, on: :create, prepend: true

  validates :namespace_ark,
            :namespace_id,
            :model_type,
            :local_original_identifier,
            :local_original_identifier_type,
            presence: true

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

  def redirect_base_url
    "#{url_base}/search/#{pid}"
  end

  private

  def set_noid
    self.noid = MinterService.call(namespace_id) if noid.blank?
  end
end
