# frozen_string_literal: true

# Be sure to restart your server when you modify this file.
#
# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.
#
# Read more: https://github.com/cyu/rack-cors
ALLOWED_ORIGINS = [
  /localhost:300[0-2]/,
  /127\.0\.0\.1:300[0-2]/,
  /https:\/\/(.*?)\.bpl\.org/,
  /https:\/\/(.*?)\.digitalcommonwealth\.org/
].freeze

Rails.application.config.middleware.insert_before 0, Rack::Cors, logger: (-> { Rails.logger }) do
  allow do
    origins(*ALLOWED_ORIGINS)

    resource '/api/v2/*',
             headers: :any,
             methods: [:get, :head, :post, :options, :delete],
             expose: ['ETag', 'Last-Modified'],
             max_age: 24.hours

    resource '/ark:/:namespace/:noid',
             headers: :any,
             methods: [:get, :post, :head, :options],
             credentials: true
  end

  allow do
    origins '*'
    resource '/ark:/:namespace/:noid',
             headers: :any,
             methods: [:get, :post, :head, :options]

    resource '/ark:/*/thumbnail',
             headers: :any,
             methods: [:get, :post, :head, :options],
             expose: ['ETag', 'Last-Modified', 'Content-Range'],
             max_age: 24.hours

    resource '/ark:/*/large_image',
             headers: :any,
             methods: [:get, :head, :options],
             max_age: 24.hours,
             expose: ['ETag', 'Last-Modified', 'Content-Range']

    resource '/ark:/*/full_image',
             headers: :any,
             methods: [:get, :head, :options],
             expose: ['ETag', 'Last-Modified', 'Content-Range'],
             max_age: 24.hours

    resource '/ark:/*/manifest',
             headers: :any,
             methods: [:get, :head, :options],
             expose: ['ETag', 'Last-Modified'],
             max_age: 12.hours

    resource '/ark:/*/annotation/:annotation_object_id',
             headers: :any,
             methods: [:get, :head, :options],
             expose: ['ETag', 'Last-Modified'],
             max_age: 12.hours

    resource '/ark:/*/canvas/:canvas_object_id',
             headers: :any,
             methods: [:get, :head, :options],
             expose: ['ETag', 'Last-Modified'],
             max_age: 12.hours

    resource '/ark:/*/iiif_search',
             headers: :any,
             methods: [:get, :head, :options]

    resource '/ark:/*/iiif_collection',
             headers: :any,
             methods: [:get, :head, :options]
  end
end
