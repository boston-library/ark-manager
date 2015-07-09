# returns preview (thumbnail), large, and full-size JPEG images
class PreviewController < ApplicationController

  # return a thumbnail-size JPEG image file for 'thumbnail' requests
  def thumbnail
    return_image_datastream(params[:noid], 'thumbnail300', '_thumbnail')
  end

  # return a full-size JPEG image file for 'full_image' requests
  def full_image
    return_image_datastream(params[:noid], nil, '_full')
  end

  # return a large-size JPEG image file for 'large_image' requests
  def large_image
    return_image_datastream(params[:noid], 'access800', '_large')
  end

  private

  # sends an image datastream to the client
  # for flagged items, return the image icon
  def return_image_datastream(noid, datastream_id=nil, file_suffix)
    ark = Ark.where(:noid => noid).first
    if ark
      model = ark.model_type
      fedora_pid = "#{ark.namespace_id}:#{ark.noid}"
      if /File\z/ =~ model || /OAIObject\z/ =~ model
        filename = fedora_pid + file_suffix
        datastream_url = image_url(fedora_pid, file_suffix, datastream_id)
      else
        solr_response = ActiveFedora::Base.find_with_conditions('id'=>"#{fedora_pid}").first
        if solr_response['exemplary_image_ssi']
          filename = solr_response['id'].to_s + file_suffix
          if solr_response['flagged_content_ssi']
            send_icon(filename)
          else
            datastream_url = image_url(solr_response['exemplary_image_ssi'], file_suffix, datastream_id)
          end
        else
          not_found
        end
      end
      if filename && datastream_url
        response = Typhoeus::Request.get(datastream_url)
        if response.code == 404
          not_found
        else
          send_image(filename, response.body)
        end
      end
    else
      not_found
    end
  end

  # returns a Fedora datastream url or IIIF url
  def image_url(pid, file_suffix, datastream_id)
    if file_suffix == '_full'
      "#{IIIF_SERVER['url']}#{pid}/full/full/0/default.jpg"
    else
      datastream_disseminator_url(pid, datastream_id)
    end
  end

  # returns the direct URL to a datastream in Fedora
  def datastream_disseminator_url pid, datastream_id
    ActiveFedora::Base.connection_for_pid(pid).client.url + "/objects/#{pid}/datastreams/#{datastream_id}/content"
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def send_icon(filename)
    send_file File.join(Rails.root, 'app', 'assets', 'images', 'dc_image-icon.png'),
              :filename => filename + '.png',
              :type => :png,
              :disposition => 'inline'
  end

  def send_image(filename, binary)
    send_data binary,
              :filename => filename + '.jpg',
              :type => :jpg,
              :disposition => 'inline'
  end


end
