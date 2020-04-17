# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Ark Manager V2 API Endpoints', type: :request, swagger_doc: 'v2/swagger.json' do
  path '/api/{version}/arks' do
    post 'Create Ark' do
      tags 'Arks'
      description 'Endpoints for Creating or Restoring Arks and returns JSON'
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
          model_type: { type: 'string', nullable: true },
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
        let(:version) { 'invalid_version' }
        let(:ark) { attributes_for(:ark, :institution_ark).slice(:local_original_identifier, :local_original_identifier_type, :namespace_ark, :namespace_id, :url_base, :model_type) }
        run_test!
      end

      response '422', 'Invalid Object' do
        let(:version) { 'v2' }
        let(:ark) { attributes_for(:ark, :invalid_ark).slice(:local_original_identifier, :local_original_identifier_type, :namespace_ark, :namespace_id, :url_base, :model_type) }
        run_test!
      end

      response '201', 'Ark created' do
        let(:version) { 'v2' }
        let(:ark) { attributes_for(:ark, :institution_ark).slice(:local_original_identifier, :local_original_identifier_type, :namespace_ark, :namespace_id, :url_base, :model_type) }
        run_test!
      end
      # TODO: Add restore and found responses.
    end
  end

  path '/api/{version}/arks/{id}' do
    get 'Retreive JSON Ark' do
      tags 'Arks'
      description 'Fetches individual arks as json'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :version, in: :path, type: :string
      parameter name: :id, in: :path, type: :string

      response '200', 'Found Ark by #id' do
        # TODO: Make this schema global in swagger_helper and reference it
        # schema type: 'object',
        #       properties: {
        #         id: { type: 'integer' },
        #         pid: { type: 'string' },
        #         created_at: { type: 'string' },
        #         updated_at: { type: 'string' },
        #         local_original_identifier: { type: 'string' },
        #         local_original_identifier_type: { type: 'string' },
        #         namespace_ark: { type: 'string' },
        #         namespace_id: { type: 'string' },
        #         url_base: { type: 'string' },
        #         model_type: { type: 'string', nullable: true },
        #         secondary_parent_pids: {
        #           type: 'object',
        #           additionalProperties: {
        #             type: 'array',
        #             items: { type: 'string' }
        #           }
        #         },
        #       },
        #       required: ['id', 'pid', 'created_at', 'updated_at' ,'local_original_identifier', 'local_original_identifier_type', 'namespace_ark', 'namespace_id', 'url_base', 'model_type', 'secondary_parent_pids']

        let(:version) { 'v2' }
        let(:id) { create(:ark, :institution_ark).id }
        run_test!
      end

      response '200', 'Found Ark by #pid' do
        let(:version) { 'v2' }
        let(:id) { create(:ark, :institution_ark).pid }
        run_test!
      end

      response '404', 'Route not found' do
        let(:version) { 'invalid_version' }
        let(:id) { 1 }
        run_test!
      end

      response '404', 'Ark not found' do
        let(:version) { 'v2' }
        let(:id) { 'commonwealth:notapid12' }
        run_test!
      end
    end
  end
end
