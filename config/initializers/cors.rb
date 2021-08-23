# frozen_string_literal: true

# Be sure to restart your server when you modify this file.
#
# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.
#
# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors, logger: (-> { Rails.logger }) do
  allow do
    origins(/localhost:300[0-2]/, /127\.0\.0\.1:300[0-2]/, 'search-dc3dev.bpl.org', 'search.digitalcommonwealth.org')

    resource '/api/v2/*',
             headers: :any,
             methods: [:get, :head, :post, :options],
             expose: ['etag'],
             credentials: false

    resource '/ark:/:namespace/:noid',
             headers: :any,
             methods: [:get, :post, :head, :options],
             max_age: 12.hours,
             credentials: false

    resource '/ark:/*/thumbnail',
             headers: :any,
             methods: [:get, :post, :head, :options],
             max_age: 12.hours,
             credentials: false

    resource '/ark:/*/large_image',
             headers: :any,
             methods: [:get, :head, :options],
             max_age: 12.hours,
             credentials: false

    resource '/ark:/*/large_image',
             headers: :any,
             methods: [:get, :head, :options],
             max_age: 12.hours,
             credentials: false
  end
end
