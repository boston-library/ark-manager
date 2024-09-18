# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TextController, type: :controller do
  let!(:digital_object_ark) { create(:ark, :object_ark, noid: 'js956f80d') }
  let!(:filestream_text_ark) { create(:ark, :filestream_text_ark, noid: '8c97kq405', parent_pid: digital_object_ark) }

  render_views

  describe '#show' do
    context ':ark.model_type is Curator::DigitalObject' do
      let!(:valid_params) { { ark: 'ark:', namespace: digital_object_ark.namespace_ark, noid: digital_object_ark.noid } }

      around(:each) { |spec| VCR.use_cassette("controllers/text/#{digital_object_ark.pid}/show", &spec) }

      it 'expects to get a plain text response' do
        get :show, params: valid_params
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('text/plain; charset=utf-8')
      end
    end

    context ':ark.model_type is Curator::Filestreams::Text' do
      let!(:valid_params) { { ark: 'ark:', namespace: filestream_text_ark.namespace_ark, noid: filestream_text_ark.noid } }

      around(:each) { |spec| VCR.use_cassette("controllers/text/#{filestream_text_ark.pid}/show", &spec) }

      it 'expects to get a plain text response' do
        get :show, params: valid_params
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('text/plain; charset=utf-8')
      end
    end

    context 'invalid :noid' do
      let!(:invalid_params) { { ark: 'ark:', namespace: digital_object_ark.namespace_ark, noid: 'nonexistent' } }

      around(:each) { |spec| VCR.use_cassette("controllers/text/nonexistent/show", &spec) }

      it 'expects to get a 404 response' do
        get :show, params: invalid_params
        expect(response).to have_http_status(:not_found)
        expect(response.body).to be_empty
      end
    end
  end
end