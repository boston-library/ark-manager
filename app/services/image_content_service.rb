# frozen_string_literal: true

class ImageContentService < ApplicationService
  attr_reader :filestream_attachment_name, :filestream_key, :file_suffix

  def initialize(filestream_attachment_name, filestream_key, file_suffix)
    @filestream_attachment_name = filestream_attachment_name
    @filestream_key = filestream_key
    @file_suffix = file_suffix
  end

  def filestream_ark_id
    return if filestream_key.blank?

    filestream_key.split('/').last
  end

  def call
    begin
      response = Down.download(image_url, headers: { 'User-Agent' => 'BPL-Ark-Manager/2' })
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

    status_symbol.downcase.tr(' ', '_').to_sym
  end

  def image_url
    return "#{iiif_server_url}#{filestream_ark_id}/full/full/0/default.jpg" if file_suffix == '_full'

    "#{derivatives_url}/#{filestream_key}/#{filestream_attachment_name}.jpg"
  end

  def iiif_server_url
    ret = ENV.fetch('IIIF_SERVER_URL') { Rails.application.secrets.dig(:iiif_server_url) }.to_s

    raise 'No value present for iiif server url' if ret.blank?

    ret
  end

  def derivatives_url
    ret = ENV.fetch('AZURE_DERIVATIVES_URL') { Rails.application.secrets.dig(:azure, :derivatives_url) }.to_s

    raise 'No value present for azure deriavtives url' if ret.blank?

    ret
  end
end
