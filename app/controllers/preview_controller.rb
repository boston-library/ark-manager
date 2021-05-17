# returns preview (thumbnail), large, and full-size JPEG images
class PreviewController < ApplicationController
  include ActionController::DataStreaming
  include ActionController::Helpers
  helper PreviewsHelper

  class PreviewServiceError < StandardError
    attr_reader :status

    def initalize(msg = 'Sever Error', status = :internal_server_error)
      @status = status
      super(msg)
    end
  end

  class ImageNotFound < StandardError; end

  # return a thumbnail-size JPEG image file for 'thumbnail' requests
  def thumbnail
    send_image_data('image_thumbnail_300', '_thumbnail')
  end

  # return a full-size JPEG image file for 'full_image' requests
  def full_image
    send_image_data(nil, '_full')
  end

  # return a large-size JPEG image file for 'large_image' requests
  def large_image
    send_image_data('image_access_800', '_large')
  end

  private

  def send_image_data(filestream_id = nil, file_suffix)
    model_type = @ark.model_type
    filename = "#{@ark.pid}#{file_suffix}"

    solr_resp = SolrService.call(@ark.pid)

    handle_preview_service_error!(solr_resp) if !solr_resp.success?

    send_icon(filename) and return if solr_resp.explicit?

    solr_doc = solr_resp.result

    filestream_key = case model_type
                      when /Filestream\z/
                        solr_doc['storage_key_base_ss']
                      else
                        solr_response['exemplary_image_key_base_ss']
                      end
    not_found!("No storage_key_base_ss or exemplary_image_key_base_ss found In Solr Doc") if filestream_key.blank?

    image_data_resp = ImageContentService.call(@ark.pid, filestream_id, filestream_key, file_suffix)

    handle_preview_service_error!(image_data_resp) if !image_data_resp.success?

    send_image(file_name, image_data_resp.result.path)
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
