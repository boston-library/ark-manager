# frozen_string_literal: true

class TextPlainContentService < ApplicationService
  attr_reader :file_stream_key
  def initialize(file_stream_key)
    @file_stream_key = file_stream_key
  end

  def call
    begin
      return Rails.cache.fetch([file_stream_key, 'text_plain_content'], expires_in: 1.week) do
        retrieve_file
      end
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
    rescue StandardError => e
      status = :internal_server_error
      error.add(status, e.message)
    end
    nil
  end

  private

  def retrieve_file
    puts text_plain_url
    begin
      io = Down.download(text_plain_url, headers: { 'User-Agent' => 'BPL-Ark-Manager/2' })
      io.read
    ensure
      io.close if io
    end
  end

  def get_status_symbol(code = nil)
    return if code.blank? || code == 0

    status_symbol = Rack::Utils::HTTP_STATUS_CODES[code].presence.to_s

    return if status_symbol.blank?

    status_symbol.downcase.tr(' ', '_').to_sym
  end

  def text_plain_url
    "#{derivatives_url}/#{file_stream_key}/text_plain.txt"
  end

  def derivatives_url
    ret = ENV.fetch('AZURE_DERIVATIVES_URL') { Rails.application.credentials.dig(:azure, :derivatives_url) }.to_s

    raise 'No value present for azure deriavtives url' if ret.blank?

    ret
  end
end