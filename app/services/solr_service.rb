class SolrService
  class << self
    def call(identifier)
      new(identifier).call
    end
  end

  def initialize(identifier)
    @solr_conn = init_solr(build_connection)
    @identifier = identifier
  end


  def call
    begin
      response = @solr_conn.get 'select', params: {q: "id:#{@identifier}", start:'0', rows: '1', fl: 'id,exemplary_image_ssi,flagged_content_ssi'}
      return response['response']['docs'].first
    rescue => e
      Rails.logger.error "Error Retreiving Solr Docs for #{@identifier}"
      Rails.logger.error "Reason: #{e.message}"
    end
    {}
  end

  private
  def init_solr(conn)
    RSolr.connect conn, url: SOLR_CONFIG[:url]
  end

  def build_connection
    Faraday.new do |f|
      f.use :http_cache, store: Rails.cache
      f.use Faraday::Response::Logger, Rails.logger
      f.adapter :net_http_persistent, pool_size: ENV.fetch("RAILS_MAX_THREADS") { 5 } do |http|
        # yields Net::HTTP::Persistent
        http.idle_timeout = 100
        http.retry_change_requests = true
      end
    end
  end
end
