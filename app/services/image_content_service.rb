# frozen_string_literal: true

class ImageContentService < ApplicationService
   attr_reader :solr_response, :filestream_id, :file_suffix
end
