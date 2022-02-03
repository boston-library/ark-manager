# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Ark Manager V2 Endpoints', type: :request, swagger_doc: 'v2/ark_manager_swagger.json' do
  describe 'JSON API Enpoints' do
    let!(:valid_version) { 'v2' }
    path '/api/{version}/arks' do
      post 'Create Ark' do
        tags 'Arks', 'Create', 'Restore', 'JSON'
        description 'Endpoints for Creating or Restoring Arks and returns JSON'
        operationId 'createOrRestoreArk'
        consumes 'application/json'
        produces 'application/json'
        parameter name: :version, in: :path, type: :string
        parameter name: :ark, in: :body, schema: {
          type: 'object',
          properties: {
            local_original_identifier: { type: 'string' },
            local_original_identifier_type: { type: 'string' },
            namespace_ark: { type: 'string' },
            namespace_id: { type: 'string' },
            url_base: { type: 'string' },
            parent_pid: { type: 'string', nullable: true },
            model_type: { type: 'string' },
            secondary_parent_pids: {
              type: 'object',
              additionalProperties: {
                type: 'array',
                items: { type: 'string' }
              }
            }
          },
          required: ['local_original_identifier', 'local_original_identifier_type', 'namespace_ark', 'namespace_id', 'url_base', 'model_type']
        }

        response '404', 'Route not found' do
          schema '$ref' => '#/components/schemas/errors_map'

          let(:version) { 'invalid_version' }
          let(:ark) { attributes_for(:ark, :institution_ark).slice(:local_original_identifier, :local_original_identifier_type, :namespace_ark, :namespace_id, :url_base, :model_type) }
          run_test!
        end

        response '422', 'Invalid Object' do
          schema '$ref' => '#/components/schemas/errors_map'

          let(:version) { valid_version }
          let(:ark) { attributes_for(:ark, :invalid_ark).slice(:local_original_identifier, :local_original_identifier_type, :namespace_ark, :namespace_id, :url_base, :model_type) }
          run_test!
        end

        response '200', 'Existing Ark Found' do
          schema '$ref' => '#/components/schemas/arks'
          let(:version) { valid_version }
          let(:ark) do
            parent_pid = create(:ark, :institution_ark).pid
            create(:ark, :collection_ark, parent_pid: parent_pid).attributes.slice('local_original_identifier', 'local_original_identifier_type', 'namespace_ark', 'namespace_id', 'url_base', 'model_type', 'parent_pid')
          end
          run_test!
        end

        response '201', 'Ark created' do
          schema '$ref' => '#/components/schemas/arks'

          let(:version) { valid_version }
          let(:ark) { attributes_for(:ark, :institution_ark).slice(:local_original_identifier, :local_original_identifier_type, :namespace_ark, :namespace_id, :url_base, :model_type) }
          run_test!
        end

        response '202', 'Deleted Ark Restored' do
          schema '$ref' => '#/components/schemas/arks'

          let(:version) { valid_version }
          let(:ark) do
            create(:ark, :institution_ark, deleted: true).attributes.slice('local_original_identifier', 'local_original_identifier_type', 'namespace_ark', 'namespace_id', 'url_base', 'model_type')
          end
          run_test!
        end
      end
    end

    path '/api/{version}/arks/{id}' do
      get 'Retreive JSON Ark' do
        tags 'Arks', 'Show', 'JSON'
        operationId 'Show Ark JSON'
        description 'Fetches individual arks as json'
        consumes 'application/json'
        produces 'application/json'
        parameter name: :version, in: :path, type: :string
        parameter name: :id, in: :path, type: :string

        response '200', 'Found Ark by #id' do
          schema '$ref' => '#/components/schemas/arks'

          let(:version) { 'v2' }
          let(:id) { create(:ark, :institution_ark).id }
          run_test!
        end

        response '200', 'Found Ark by #pid' do
          schema '$ref' => '#/components/schemas/arks'

          let(:version) { valid_version }
          let(:id) { create(:ark, :institution_ark).pid }
          run_test!
        end

        response '404', 'Route not found' do
          schema '$ref' => '#/components/schemas/errors_map'

          let(:version) { 'invalid_version' }
          let(:id) { 1 }
          run_test!
        end

        response '404', 'Ark not found' do
          schema '$ref' => '#/components/schemas/errors_map'

          let(:version) { valid_version }
          let(:id) { 'commonwealth:notapid12' }
          run_test!
        end

        response '404', 'Deleted Ark not found' do
          schema '$ref' => '#/components/schemas/errors_map'

          let(:version) { valid_version }
          let(:id) { create(:ark, deleted: true).id }
          run_test!
        end
      end

      delete 'Soft Delete Ark' do
        tags 'Arks', 'Soft-Delete', 'JSON', 'No-Content'
        operationId 'SoftDeleteArk'
        consumes 'application/json'
        produces 'text/html', 'application/json'
        parameter name: :version, in: :path, type: :string
        parameter name: :id, in: :path, type: :string

        response '204', 'Ark(by #id) Soft Deleted' do
          let(:version) { valid_version }
          let(:id) { create(:ark).id }
          run_test!
        end

        response '204', 'Ark(by #pid) Soft Deleted' do
          let(:version) { valid_version }
          let(:id) { create(:ark).pid }
          run_test!
        end

        response '404', 'Route not found' do
          schema '$ref' => '#/components/schemas/errors_map'

          let(:version) { 'invalid_version' }
          let(:id) { 1 }
          run_test!
        end

        response '404', 'Ark not found' do
          schema '$ref' => '#/components/schemas/errors_map'

          let(:version) { valid_version }
          let(:id) { 'commonwealth:notapid12' }
          run_test!
        end

        response '404', 'Already deleted Ark not found' do
          schema '$ref' => '#/components/schemas/errors_map'

          let(:version) { valid_version }
          let(:id) { create(:ark, deleted: true).id }
          run_test!
        end
      end
    end
  end
end
