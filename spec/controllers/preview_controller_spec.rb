# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PreviewController, type: :controller do
  let!(:digital_object_ark) { create(:ark, :object_ark, noid: 'j6731q74d') }
  let!(:filestream_image_ark) { create(:ark, :filestream_image_ark, noid: 'j6731q75p') }

  render_views

  describe '#thumbnail' do
    context ':ark.#model_type is Curator::DigitalObject' do
      let!(:valid_params) { { ark: 'ark:', namespace: digital_object_ark.namespace_ark, noid: digital_object_ark.noid } }

      around(:each) { |spec| VCR.use_cassette("controllers/preview/#{digital_object_ark.pid}_thumbnail", &spec) }

      it 'expects to get a send_file response' do
        get :thumbnail, params: valid_params
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('image/jpeg')
      end
    end

    context ':ark.#model_type is Curator::Filestreams::Image' do
      let!(:valid_params) { { ark: 'ark:', namespace: filestream_image_ark.namespace_ark, noid: filestream_image_ark.noid } }

      around(:each) { |spec| VCR.use_cassette("controllers/preview/#{filestream_image_ark.pid}_thumbnail", &spec) }

      it 'expects to get a send_file response' do
        get :thumbnail, params: valid_params
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('image/jpeg')
      end
    end

    context 'invalid :noid' do
      let!(:invalid_params) { { ark: 'ark:', namespace: digital_object_ark.namespace_ark, noid: 'nonexistent' } }

      it 'expects to get a 404 response' do
        get :thumbnail, params: invalid_params
        expect(response).to have_http_status(:not_found)
        expect(response.body).to be_empty
      end
    end
  end

  describe '#full_image' do
    context ':ark.#model_type is Curator::DigitalObject' do
      let!(:valid_params) { { ark: 'ark:', namespace: digital_object_ark.namespace_ark, noid: digital_object_ark.noid } }

      around(:each) { |spec| VCR.use_cassette("controllers/preview/#{digital_object_ark.pid}_full_image", &spec) }

      it 'expects to get a send_file response' do
        get :full_image, params: valid_params
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('image/jpeg')
      end
    end

    context ':ark.#model_type is Curator::Filestreams::Image' do
      let!(:valid_params) { { ark: 'ark:', namespace: filestream_image_ark.namespace_ark, noid: filestream_image_ark.noid } }

      around(:each) { |spec| VCR.use_cassette("controllers/preview/#{filestream_image_ark.pid}_full_image", &spec) }

      it 'expects to get a send_file response' do
        get :full_image, params: valid_params
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('image/jpeg')
      end
    end

    context 'invalid :noid' do
      let!(:invalid_params) { { ark: 'ark:', namespace: digital_object_ark.namespace_ark, noid: 'nonexistent' } }

      it 'expects to get a 404 response' do
        get :full_image, params: invalid_params
        expect(response).to have_http_status(:not_found)
        expect(response.body).to be_empty
      end
    end
  end

  describe '#large_image' do
    context ':ark.#model_type is Curator::DigitalObject' do
      let!(:valid_params) { { ark: 'ark:', namespace: digital_object_ark.namespace_ark, noid: digital_object_ark.noid } }

      around(:each) { |spec| VCR.use_cassette("controllers/preview/#{digital_object_ark.pid}_large_image", &spec) }

      it 'expects to get a send_file response' do
        get :large_image, params: valid_params
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('image/jpeg')
      end
    end

    context ':ark.#model_type is Curator::Filestreams::Image' do
      let!(:valid_params) { { ark: 'ark:', namespace: filestream_image_ark.namespace_ark, noid: filestream_image_ark.noid } }

      around(:each) { |spec| VCR.use_cassette("controllers/preview/#{filestream_image_ark.pid}_large_image", &spec) }

      it 'expects to get a send_file response' do
        get :large_image, params: valid_params
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('image/jpeg')
      end
    end

    context 'invalid :noid' do
      let!(:invalid_params) { { ark: 'ark:', namespace: digital_object_ark.namespace_ark, noid: 'nonexistent' } }

      it 'expects to get a 404 response' do
        get :large_image, params: invalid_params
        expect(response).to have_http_status(:not_found)
        expect(response.body).to be_empty
      end
    end
  end
end
