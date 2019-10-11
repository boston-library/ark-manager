class Ark < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, sequence_separator: ':'

  scope :active, -> { where(deleted: false) }
  scope :by_parent_pid, ->(parent_id) { where(parent_id: parent_pid) }
  scope :by_local_original_identifier, ->(identifier, identifier_type) { where(local_original_identifier: identifier, local_original_identifier_type: identifier_type) }

  before_validation :set_noid, on: :create, prepend: true #Need to add this to the callback list due to firendly id also using a before validation
  validates :namespace_ark, :url_base, :noid, :namespace_id, :model_type, :local_original_identifier, :local_original_identifier_type, presence: true

  validates_uniqueness_of :noid, allow_blank: true
  validates_format_of :url_base, with: URI.regexp(['http', 'https']), allow_blank: true


  def slug_candidates
    [
      [:namespace_id, :noid]
    ]
  end#Needed for friendly id

  def redirect_base_url
    "#{url_base}/search/#{pid}"
  end
  # def to_s
  # end

  private
  def set_noid
    puts "Setting Noid"
    self.noid =  minter_service.mint
  end

  def minter_service
    Noid::Rails::Service.new
  end
end
