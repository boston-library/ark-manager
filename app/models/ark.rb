class Ark < ApplicationRecord
  default_scope { where(deleted: false) }

  before_validation :set_noid, on: :create

  validates :namespace_ark, :url_base, :noid, :namespace_id, :model_type, :local_original_identifier, :local_original_identifier_type, presence: true

  validates_uniqueness_of :noid, allow_blank: true
  validates_format_of :url_base, with: URI.regexp(['http', 'https']), allow_blank: true


  def pid
    "#{namespace_id}:#{noid}"
  end

  def redirect_base_url
    "#{url_base}/search/#{pid}"
  end

  private
  def set_noid
    puts "Setting Noid"
    self.noid = Rails.application.executor.wrap { MinterService.call }
  end
end
