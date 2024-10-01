# frozen_string_literal: true

class TextController < ApplicationController
  include ActionController::DataStreaming
  class TextNotFound < StandardError; end

  class TextPlainServiceError < StandardError
    attr_reader :status

    def initialize(msg = 'Sever Error', status = :internal_server_error)
      @status = status
      super(msg)
    end
  end

  before_action :find_ark, only: :show
  def show
    plain_text_data = fetch_plain_text_data

    expires_in 1.week

    render plain: plain_text_data
  end

  protected

  def fetch_plain_text_data
    model_type = @ark.model_type
    solr_resp = SolrService.call(@ark.pid)

    handle_text_plain_service_error!(solr_resp) if solr_resp.failure?

    not_found!('This resource does not have any OCR/Transcribed text associated with it') unless solr_resp.has_text?

    solr_doc = solr_resp.result

    filestream_key = case model_type
                     when /Filestreams/
                       solr_doc['storage_key_base_ss']
                     else
                       solr_doc['transcription_key_base_ss']
                     end

    not_found!("No 'storage_key_base_ss' or 'transcription_key_base_ss' found In solr response doc") if filestream_key.blank?

    text_plain_content_resp = TextPlainContentService.call(filestream_key)

    handle_text_plain_service_error!(text_plain_content_resp) if text_plain_content_resp.failure?

    text_plain_content_resp.result
  end

  private

  def not_found!(msg)
    raise TextNotFound, msg
  end

  def handle_text_plain_service_error!(service_resp)
    status = service_resp.errors.keys.first || :internal_server_error
    msg = service_resp.errors.full_messages.join(', ')
    raise TextPlainServiceError.new(msg, status)
  end

  def find_ark
    @ark = Ark.active.find_by!(noid: params[:noid])
  end
end
