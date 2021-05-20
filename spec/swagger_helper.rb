# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    'v2/ark_manager_swagger.json' => {
      openapi: '3.0.1',
      info: {
        title: 'API V2',
        version: 'v2',
        description: 'Ark Manager Version 2 API endpoints'
      },
      paths: {},
      components: {
        schemas: {
          arks: {
            type: 'object',
            properties: {
              id: { type: 'integer' },
              pid: { type: 'string' },
              created_at: { type: 'string' },
              updated_at: { type: 'string' },
              local_original_identifier: { type: 'string' },
              local_original_identifier_type: { type: 'string' },
              namespace_ark: { type: 'string' },
              namespace_id: { type: 'string' },
              parent_pid: { type: 'string', nullable: true },
              url_base: { type: 'string' },
              model_type: { type: 'string' },
              secondary_parent_pids: {
                type: 'array',
                items: { type: 'string' }
              },
              required: ['id', 'pid', 'created_at', 'updated_at', 'local_original_identifier', 'local_original_identifier_type', 'namespace_ark', 'namespace_id', 'url_base', 'model_type', 'secondary_parent_pids']
            }
          },
          errors_map: {
            type: 'object',
            properties: {
              errors: {
                type: 'array',
                items: { '$ref' => '#/components/schemas/error_object' }
              }
            }
          },
          error_object: {
            type: 'object',
            properties: {
              title: { type: 'string' },
              status: { type: 'integer' },
              detail: { type: 'string' },
              source: {
                type: 'object',
                properties: {
                  pointer: { type: 'string' }
                }
              }
            }
          }
        }
      },
      servers: [
        {
          url: 'http://{defaultHost}',
          variables: {
            defaultHost: {
              default: '127.0.0.1:3000'
            }
          }
        }
      ]
    },
    'object_in_view.json' => {
      openapi: '3.0.1',
      info: {
        title: 'Object In View',
        description: 'Permalink and IIIF endpoints for Arks'
      },
      paths: {},
      components: {},
      servers: [
        {
          url: 'http://{defaultHost}',
          variables: {
            defaultHost: {
              default: '127.0.0.1:3000'
            }
          }
        }
      ]
    },
    'image_previews.json' => {
      openapi: '3.0.1',
      info: {
        title: 'Image Previews',
        description: 'Endpoints for previewing varying images for Ark'
      },
      paths: {},
      components: {},
      servers: [
        {
          url: 'http://{defaultHost}',
          variables: {
            defaultHost: {
              default: '127.0.0.1:3000'
            }
          }
        }
      ]
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :json
end
