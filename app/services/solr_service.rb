# frozen_string_literal: true

class SolrService < ApplicationService
  class << self
    def solr_client
      return @solr_client if defined?(@solr_client)

      conn = Faraday.new do |builder|
        builder.response :logger, Rails.logger
        builder.adapter :net_http_persistent, pool: ENV.fetch('RAILS_MAX_THREADS', 5) do |http|
          http.idle_timeout = 120
        end
      end

      @solr_client = RSolr.connect conn, :url => ENV.fetch('CURATOR_SOLR_URL')
    end
  end

  attr_reader :query

  #bpl-dev:1fda3335
  def initialize(ark_id)
    @query = {'id': ark_id}
  end

  def call
    begin
      solr = self.class.solr_client.get 'get', params: query

      response = solr['doc'].presence || {}

      errors.add(:not_found, "No Solr document found with id #{query[:id]}") if response.blank?

      return response
    rescue RSolr::Error::Http => e
      errors.add(:bad_request, e.message)
    rescue RSolr::Error::ConnectionRefused => e
      errors.add(:bad_gateway, e.message)
    rescue RSolr::Error::InvalidJsonResponse => e
      errors.add(:unprocessable_entity, e.message)
    end
    {}
  end

  def explicit?
    result['flagged_content_ssi'] == 'explicit'
  end
end
