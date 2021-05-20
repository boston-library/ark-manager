# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Image Preview Endpoints', type: :request, swagger_doc: 'image_previews.json' do
  let!(:valid_ark_param) { 'ark:' }
  let!(:valid_namespace_param) { '50959' }
  let!(:valid_ark) { create(:ark, noid: 'j6731q74d') }

  path '/{ark}/{namespace}/{noid}/thumbnail' do
    get 'Ark Thumbnail' do
      tags 'Arks', 'Images', 'Thumbnail'
      produces 'image/jpeg', 'image/png', 'text/html'
      parameter name: :ark, in: :path, type: :string
      parameter name: :namespace, in: :path, type: :string
      parameter name: :noid, in: :path, type: :string

      response '200', 'Inline file response' do
        let(:ark) { valid_ark_param }
        let(:namespace) { valid_namespace_param }
        let(:noid) { valid_ark.noid }
        before(:each) do |example|
          VCR.use_cassette("requests/previews/#{valid_ark.pid}_thumbnail") do
            submit_request(example.metadata)
          end
        end
      end

      response '404', 'Invalid :ark parameter' do
        let(:ark) { 'invalid_ark_param' }
        let(:namespace) { valid_namespace_param }
        let(:noid) { 'bpl-dev:000000000' }
        run_test!
      end

      response '404', 'Ark Not Found' do
        let(:ark) { valid_ark_param }
        let(:namespace) { valid_namespace_param }
        let(:noid) { 'abcde1234' }
        run_test!
      end
    end

    post 'Ark Thumbnail' do
      tags 'Arks', 'Images', 'Thumbnail'
      produces 'image/jpeg', 'image/png', 'text/html'
      parameter name: :ark, in: :path, type: :string
      parameter name: :namespace, in: :path, type: :string
      parameter name: :noid, in: :path, type: :string

      response '200', 'Inline file response' do
        let(:ark) { valid_ark_param }
        let(:namespace) { valid_namespace_param }
        let(:noid) { valid_ark.noid }

        before(:each) do |example|
          VCR.use_cassette("requests/previews/#{valid_ark.pid}_thumbnail") do
            submit_request(example.metadata)
          end
        end

        it 'returns a valid 200 response' do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end

      response '404', 'Invalid :ark parameter' do
        let(:ark) { 'invalid_ark_param' }
        let(:namespace) { valid_namespace_param }
        let(:noid) { 'bpl-dev:000000000' }
        run_test!
      end

      response '404', 'Ark Not Found' do
        let(:ark) { valid_ark_param }
        let(:namespace) { valid_namespace_param }
        let(:noid) { 'abcde1234' }
        run_test!
      end
    end
  end

  path '/{ark}/{namespace}/{noid}/large_image' do
    get 'Ark large_image' do
      tags 'Arks', 'Images', 'Large-Image'
      produces 'image/jpeg', 'image/png', 'text/html'
      parameter name: :ark, in: :path, type: :string
      parameter name: :namespace, in: :path, type: :string
      parameter name: :noid, in: :path, type: :string

      response '200', 'Inline file response' do
        let(:ark) { valid_ark_param }
        let(:namespace) { valid_namespace_param }
        let(:noid) { valid_ark.noid }

        before(:each) do |example|
          VCR.use_cassette("requests/previews/#{valid_ark.pid}_large_image") do
            submit_request(example.metadata)
          end
        end

        it 'returns a valid 200 response' do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end

      response '404', 'Invalid :ark parameter' do
        let(:ark) { 'invalid_ark_param' }
        let(:namespace) { valid_namespace_param }
        let(:noid) { 'bpl-dev:000000000' }
        run_test!
      end

      response '404', 'Ark Not Found' do
        let(:ark) { valid_ark_param }
        let(:namespace) { valid_namespace_param }
        let(:noid) { 'abcde1234' }
        run_test!
      end
    end
  end

  path '/{ark}/{namespace}/{noid}/full_image' do
    get 'Ark Full Image' do
      tags 'Arks', 'Images', 'Large-Image'
      produces 'image/jpeg', 'image/png', 'text/html'
      parameter name: :ark, in: :path, type: :string
      parameter name: :namespace, in: :path, type: :string
      parameter name: :noid, in: :path, type: :string

      response '200', 'Inline file response' do
        let(:ark) { valid_ark_param }
        let(:namespace) { valid_namespace_param }
        let(:noid) { valid_ark.noid }

        before(:each) do |example|
          VCR.use_cassette("requests/previews/#{valid_ark.pid}_full_image") do
            submit_request(example.metadata)
          end
        end

        it 'returns a valid 200 response' do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end

      response '404', 'Invalid :ark parameter' do
        let(:ark) { 'invalid_ark_param' }
        let(:namespace) { valid_namespace_param }
        let(:noid) { 'bpl-dev:000000000' }
        run_test!
      end

      response '404', 'Ark Not Found' do
        let(:ark) { valid_ark_param }
        let(:namespace) { valid_namespace_param }
        let(:noid) { 'abcde1234' }
        run_test!
      end
    end
  end
end
