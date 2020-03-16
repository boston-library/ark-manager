class Ark < ApplicationRecord
  extend FriendlyId

  friendly_id :slug_candidates, sequence_separator: ':'

  delegate :to_s

  scope :active, -> { where(deleted: false) }
  scope :by_parent_pid, ->(parent_id) { where(parent_id: parent_pid) }
  scope :by_local_identifier, ->(identifier, identifier_type) { where(local_original_identifier: identifier, local_original_identifier_type: identifier_type) }
  scope :by_namespace_ark, ->(namespace_ark) { where(namespace_ark: namespace_ark) }

  #NOTE: Need to add this to the callback list due to firendly id also using a before validation
  before_validation :set_noid, on: :create, prepend: true

  validates :namespace_ark, :url_base, :noid, :namespace_id, :model_type, :local_original_identifier, :local_original_identifier_type, presence: true

  validates_uniqueness_of :noid, allow_blank: true
  validates_format_of :url_base, with: URI.regexp(['http', 'https']), allow_blank: true

  def to_s
    OJ.pretty_generate(as_json)
  end

  def slug_candidates
    [
      [:namespace_id, :noid]
    ]
  end#Needed for friendly id

  def redirect_base_url
    "#{url_base}/search/#{pid}"
  end


  private

  def set_noid
    puts "Setting Noid"
    self.noid =  MinterService.call(namespace: namespace_id)
  end
end
