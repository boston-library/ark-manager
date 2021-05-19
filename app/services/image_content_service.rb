# frozen_string_literal: true

class ImageContentService < ApplicationService
   attr_reader :pid, :filestream_id, :filestream_key, :file_suffix

   def initialize(pid, filestream_id, filestream_key, file_suffix)
     @pid = pid
     @filestream_id = filestream_id
     @filestream_key = filestream_key
     @file_suffix = file_suffix
   end

   def call
     begin
       response = Down.download(image_url)
       return response
     rescue Down::NotFound => e
       errors.add(:not_found, e.message)
     rescue Down::TimeoutError => e
       errors.add(:request_timeout, e.message)
     rescue Down::ClientError => e
       status = get_status_symbol(e&.response&.code.to_i) || :bad_request
       errors.add(status, e.message)
     rescue Down::ServerError => e
       status = get_status_symbol(e&.response&.code.to_i) || :internal_server_error
       errors.add(status, e.message)
     end
     nil
   end

   private

   def get_status_symbol(code = nil)
     return if code.blank? || code == 0

     status_symbol = Rack::Utils::HTTP_STATUS_CODES[code].presence.to_s

     return if status_symbol.blank?

     status_symbol.downcase.gsub(' ', '_').to_sym
   end


   def image_url
     return "#{ENV['IIIF_SERVER_URL']}#{pid}/full/full/0/default.jpg" if file_suffix == '_full'

     "#{ENV['AZURE_DERIVATIVES_URL']}/#{filestream_key}/#{filestream_id}.jpg"
   end
end
