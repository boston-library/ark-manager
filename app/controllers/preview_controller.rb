# frozen_string_literal: true

class PreviewController < ApplicationController
  DEFAULT_ICON_FILEPATH= Rails.root.join('public', 'dc_image-icon.png').to_s

  FILE_SUFFIXES = {
    thumbnail: '_thumbnail',
    large_image: '_large',
    full: '_full'
  }.freeze

  FILESTREAM_ATTACHMENT_NAMES = {
    thumbnail: 'image_thumbnail_300',
    large: 'image_access_800',
    full: nil
  }.freeze

  class ImageNotFound < StandardError; end
  class PreviewServiceError < StandardError
    attr_reader :status

    def initalize(msg = 'Sever Error', status = :internal_server_error)
      @status = status
      super(msg)
    end
  end

  include ActionController::DataStreaming

  before_action :find_ark, only: [:thumbnail, :full_image, :large_image]

  # return a thumbnail-size JPEG image file for 'thumbnail' requests
  def thumbnail
    send_image_data(FILESTREAM_ATTACHMENT_NAMES[:thumbnail], FILE_SUFFIXES[:thumbnail])
  end

  # return a full-size JPEG image file for 'full_image' requests
  def full_image
    send_image_data(FILESTREAM_ATTACHMENT_NAMES[:full], FILE_SUFFIXES[:full])
  end

  # return a large-size JPEG image file for 'large_image' requests
  def large_image
    send_image_data(FILESTREAM_ATTACHMENT_NAMES[:large], FILE_SUFFIXES[:large])
  end

  protected

  def send_image_data(filestream_attachment_name = nil, file_suffix)
    model_type = @ark.model_type
    filename = "#{@ark.pid}#{file_suffix}"

    solr_resp = SolrService.call(@ark.pid)

    handle_preview_service_error!(solr_resp) if solr_resp.failure?

    send_icon(filename) and return if solr_resp.explicit?

    solr_doc = solr_resp.result

    filestream_key = case model_type
                     when /Filestreams/
                       solr_doc['storage_key_base_ss']
                     else
                      solr_doc['exemplary_image_key_base_ss']
                     end

    not_found!("No 'storage_key_base_ss' or 'exemplary_image_key_base_ss' found In solr response doc") if filestream_key.blank?

    image_data_resp = ImageContentService.call(filestream_attachment_name, filestream_key, file_suffix)

    handle_preview_service_error!(image_data_resp) if image_data_resp.failure?

    send_image(filename, image_data_resp.result.path)
  end

  private

  def send_icon(filename)
    expires_in 1.year, public: true,  must_revalidate: true

    send_file DEFAULT_ICON_FILEPATH,
              :filename => "#{filename}.png",
              :type => :png,
              :disposition => 'inline'
  end

  def send_image(filename, file_path)
    expires_in 2.hours, public: true,  must_revalidate: true

    send_file file_path,
              :filename => "#{filename}.jpg",
              :type => :jpg,
              :disposition => 'inline'
  end

  def not_found!(msg)
    raise ImageNotFound, msg
  end

  def handle_preview_service_error!(service_resp)
    status = service_resp.errors.keys.first || :internal_server_error
    msg = service_resp.errors.full_messages.join(', ')
    raise PreviewServiceError.new(msg, status)
  end

  def find_ark
    @ark = Ark.active.find_by!(noid: params[:noid])
  end
end
