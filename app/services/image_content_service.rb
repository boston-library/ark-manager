# frozen_string_literal: true

class ImageContentService < ApplicationService
   attr_reader :pid, :filestream_id, :filestream_key, :file_suffix

   def initialize(pid, filestream_id, filestream_key, file_suffix)
     @model_type = model_type
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
       errors.add(:request_timeout)
     rescue Down::ClientError => e
       status = e&.response&.code || :bad_request
       errors.add(status, e.message)
     rescue Down::ServerError => e
       status = e&.response&.code || :internal_server_error
       errors.add(status, e.message)
     end
   end

   private

   def image_url
     return "#{ENV['IIIF_SERVER_URL']}#{pid}/full/full/0/default.jpg" if file_suffix == '_full'

     "#{ENV['AZURE_DERIVATIVES_URL']}/#{filestream_key}/#{filestream_id}.jpg"
   end
end
