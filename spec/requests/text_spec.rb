# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe "Full Text File Endpoint", type: :request, swagger_doc: 'full_text.json' do
  let!(:valid_ark_param) { 'ark:' }
  let!(:valid_namespace_param) { '50959' }
  let!(:valid_ark) { create(:ark, noid: 'js956f80d') }

  path '/{ark}/{namespace}/{noid}/text' do
    get 'Ark OCR Text File' do
      tags 'Arks', 'Text', 'OCR'
      produces 'text/plain', 'application/json', 'text/html'
      parameter name: :ark, in: :path, type: :string
      parameter name: :namespace, in: :path, type: :string
      parameter name: :noid, in: :path, type: :string

      response '200', 'Inline file response' do
        let(:ark) { valid_ark_param }
        let(:namespace) { valid_namespace_param }
        let(:noid) { valid_ark.noid }
        before(:each) do |example|
          VCR.use_cassette("requests/text/#{valid_ark.pid}") do
            submit_request(example.metadata)
          end
        end
      end

      response '404', 'Invalid :ark parameter' do
        let(:ark) { 'invalid_ark_param' }
        let(:namespace) { valid_namespace_param }
        let(:noid) { 'bpl-dev:000000000' }
        run_test! vcr: true
      end

      response '404', 'Ark Not Found' do
        let(:ark) { valid_ark_param }
        let(:namespace) { valid_namespace_param }
        let(:noid) { 'abcde1234' }
        run_test! vcr: true
      end
    end
  end
end
