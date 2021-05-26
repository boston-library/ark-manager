# frozen_string_literal: true

# Be sure to restart your server when you modify this file.
#
# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.
#
# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors, logger: (-> { Rails.logger }) do
  allow do
    origins '*'
    resource '/ark:/*/thumbnail',
             headers: :any,
             methods: [:get, :post, :head],
             max_age: 2.hours

    resource '/ark:/*/large_image',
             headers: :any,
             methods: [:get, :head],
             max_age: 2.hours

    resource '/ark:/*/large_image',
             headers: :any,
             methods: [:get, :head],
             max_age: 2.hours
  end
end
