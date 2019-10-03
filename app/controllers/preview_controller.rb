# returns preview (thumbnail), large, and full-size JPEG images
class PreviewController < ApplicationController
  class ImageNotFound < StandardError; end
  # return a thumbnail-size JPEG image file for 'thumbnail' requests
  def thumbnail
    return_image_datastream('thumbnail300', '_thumbnail')
  end

  # return a full-size JPEG image file for 'full_image' requests
  def full_image
    return_image_datastream(nil, '_full')
  end

  # return a large-size JPEG image file for 'large_image' requests
  def large_image
    return_image_datastream('access800', '_large')
  end

  private

  # sends an image datastream to the client
  # for flagged items, return the image icon
  def return_image_datastream(datastream_id=nil, file_suffix)
    model = @ark.model_type
    filename = "#{@ark.pid}#{file_suffix}"
    if /File\z/ =~ model || /OAIObject\z/ =~ model
      datastream_url = image_url(@ark.pid, file_suffix, datastream_id)
    else
      solr_response = SolrService.call(@ark.pid)
      raise ImageNotFound, "No Exemplary Image Found In Solr" if solr_response['exemplary_image_ssi'].blank?
      if solr_response['flagged_content_ssi']
        send_icon(filename)
      else
        datastream_url = image_url(solr_response['exemplary_image_ssi'], file_suffix, datastream_id)
      end
    end
    if datastream_url
      response = Typhoeus::Request.get(datastream_url)
      raise ImageNotFound, "No Image Content Found at #{datastream_url}" if response.code == 404
      send_image(filename, response.body)
    end
  end

  # returns a Fedora datastream url or IIIF url
  def image_url(pid, file_suffix, datastream_id)
    return "#{IIIF_SERVER['url']}#{pid}/full/full/0/default.jpg" if file_suffix == '_full'
    datastream_disseminator_url(pid, datastream_id)
  end

  # returns the direct URL to a datastream in Fedora
  def datastream_disseminator_url(pid, datastream_id)
    ActiveFedora::Base.connection_for_pid(pid).client.url + "/objects/#{pid}/datastreams/#{datastream_id}/content"
  end



  def send_icon(filename)
    send_file File.join(Rails.root, 'public', 'dc_image-icon.png'),
              :filename => "#{filename}.png",
              :type => :png,
              :disposition => 'inline'
  end

  def send_image(filename, binary)
    send_data binary,
              :filename => "#{filename}.jpg",
              :type => :jpg,
              :disposition => 'inline'
  end


  def find_ark
    @ark = Ark.find_by(noid: params[:noid])
    raise ActiveRecord::RecordNotFound, "Unable to locate ark with identifier-#{params[:noid]}" if @ark.blank?
  end

end
