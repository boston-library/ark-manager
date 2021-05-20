# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Ark Manager Object In View/IIIF Endpoints', type: :request, swagger_doc: 'object_in_view.json' do
  let!(:valid_ark_param) { 'ark:' }
  let!(:valid_namespace_param) { '50959' }

  describe 'Permalink Show' do
    path '/{ark}/{namespace}/{noid}' do
      get 'Ark Permalink' do
        tags 'Arks', 'Permalink', 'Redirect'
        produces 'text/html'
        parameter name: :ark, in: :path, type: :string
        parameter name: :namespace, in: :path, type: :string
        parameter name: :noid, in: :path, type: :string

        response '302', 'Permalink Redirection' do
          let(:ark) { valid_ark_param }
          let(:namespace) { valid_namespace_param }
          let(:noid) { create(:ark).noid }
          run_test!
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

  describe 'IIIF Endpoints' do
    path '/{ark}/{namespace}/{noid}/manifest' do
      get 'Ark IIIF Manifest' do
        tags 'Arks', 'IIIF', 'Manifest', 'Redirect'
        produces 'text/html'
        parameter name: :ark, in: :path, type: :string
        parameter name: :namespace, in: :path, type: :string
        parameter name: :noid, in: :path, type: :string

        response '302', 'IIIF Manifest Redirection' do
          let(:ark) { valid_ark_param }
          let(:namespace) { valid_namespace_param }
          let(:noid) { create(:ark).noid }
          run_test!
        end

        response '404', 'Invalid :ark parameter' do
          let(:ark) { 'invalid_ark_param' }
          let(:namespace) { valid_namespace_param }
          let(:noid) { 'commonwealth:000000000' }
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

    path '/{ark}/{namespace}/{noid}/canvas/{canvas_object_id}' do
      get 'Ark IIIF Canvas Object' do
        tags 'Arks', 'IIIF', 'Canvas-Object', 'Redirect'
        produces 'text/html'
        parameter name: :ark, in: :path, type: :string
        parameter name: :namespace, in: :path, type: :string
        parameter name: :noid, in: :path, type: :string
        parameter name: :canvas_object_id, in: :path, type: :string

        response '302', 'IIIF Canvas Object Redirection' do
          let(:ark) { valid_ark_param }
          let(:namespace) { valid_namespace_param }
          let(:noid) { create(:ark).noid }
          let(:canvas_object_id) { create(:ark).noid }
          run_test!
        end

        response '404', 'Invalid :ark parameter' do
          let(:ark) { 'invalid_ark_param' }
          let(:namespace) { valid_namespace_param }
          let(:noid) { 'commonwealth:000000000' }
          let(:canvas_object_id) { create(:ark).noid }
          run_test!
        end

        response '404', 'Ark Not Found' do
          let(:ark) { valid_ark_param }
          let(:namespace) { valid_namespace_param }
          let(:noid) { 'abcde1234' }
          let(:canvas_object_id) { create(:ark).noid }
          run_test!
        end

        response '404', 'Canvas Ark Not Found' do
          let(:ark) { valid_ark_param }
          let(:namespace) { valid_namespace_param }
          let(:noid) { create(:ark).noid }
          let(:canvas_object_id) { 'abcde1234' }
          run_test!
        end
      end
    end

    path '/{ark}/{namespace}/{noid}/annotation/{annotation_object_id}' do
      get 'Ark IIIF Annotation Object' do
        tags 'Arks', 'IIIF', 'Annotation-Object', 'Redirect'
        produces 'text/html'
        parameter name: :ark, in: :path, type: :string
        parameter name: :namespace, in: :path, type: :string
        parameter name: :noid, in: :path, type: :string
        parameter name: :annotation_object_id, in: :path, type: :string

        response '302', 'IIIF Annotation Object Redirection' do
          let(:ark) { valid_ark_param }
          let(:namespace) { valid_namespace_param }
          let(:noid) { create(:ark).noid }
          let(:annotation_object_id) { create(:ark).noid }
          run_test!
        end

        response '404', 'Invalid :ark parameter' do
          let(:ark) { 'invalid_ark_param' }
          let(:namespace) { valid_namespace_param }
          let(:noid) { 'commonwealth:000000000' }
          let(:annotation_object_id) { create(:ark).noid }
          run_test!
        end

        response '404', 'Ark Not Found' do
          let(:ark) { valid_ark_param }
          let(:namespace) { valid_namespace_param }
          let(:noid) { 'abcde1234' }
          let(:annotation_object_id) { create(:ark).noid }
          run_test!
        end

        response '404', 'Annotation Ark Not Found' do
          let(:ark) { valid_ark_param }
          let(:namespace) { valid_namespace_param }
          let(:noid) { create(:ark).noid }
          let(:annotation_object_id) { 'abcde1234' }
          run_test!
        end
      end
    end

    path '/{ark}/{namespace}/{noid}/iiif_collection' do
      get 'Ark IIIF Collection' do
        tags 'Arks', 'IIIF', 'Collection', 'Redirect'
        produces 'text/html'
        parameter name: :ark, in: :path, type: :string
        parameter name: :namespace, in: :path, type: :string
        parameter name: :noid, in: :path, type: :string

        response '302', 'IIIF Collection Redirection' do
          let(:ark) { valid_ark_param }
          let(:namespace) { valid_namespace_param }
          let(:noid) { create(:ark).noid }
          run_test!
        end

        response '404', 'Invalid :ark parameter' do
          let(:ark) { 'invalid_ark_param' }
          let(:namespace) { valid_namespace_param }
          let(:noid) { 'commonwealth:000000000' }
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

    path '/{ark}/{namespace}/{noid}/iiif_search' do
      get 'Ark IIIF Search' do
        tags 'Arks', 'IIIF', 'Search', 'Redirect'
        produces 'text/html'
        parameter name: :ark, in: :path, type: :string
        parameter name: :namespace, in: :path, type: :string
        parameter name: :noid, in: :path, type: :string
        parameter name: :q, in: :query, type: :string, required: false

        response '302', 'IIIF Search Redirection' do
          let(:ark) { valid_ark_param }
          let(:namespace) { valid_namespace_param }
          let(:noid) { create(:ark).noid }
          run_test!
        end

        response '302', 'IIIF Search Redirection With Query' do
          let(:ark) { valid_ark_param }
          let(:namespace) { valid_namespace_param }
          let(:noid) { create(:ark).noid }
          let(:q) { 'birds' }
          run_test!
        end

        response '404', 'Invalid :ark parameter' do
          let(:ark) { 'invalid_ark_param' }
          let(:namespace) { valid_namespace_param }
          let(:noid) { 'commonwealth:000000000' }
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
end
