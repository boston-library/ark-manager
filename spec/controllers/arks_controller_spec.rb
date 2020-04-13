# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArksController, type: :controller do
  describe '#show' do
    let!(:ark) { create(:ark) }

    context 'json response' do
      render_views

      let!(:expected_response) do
        ark_json = ark.as_json(root: true,  except: [:deleted, :noid] )
        %w(created_at updated_at).each do |date_attr|
          ark_json['ark'][date_attr] = ark_json['ark'][date_attr].as_json
        end
        ark_json
      end

      context 'by #id' do
        let!(:params) { { id: ark.id, version: 'v2', format: :json } }

        it 'returns a successful json response' do
          get :show, params: params
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq('application/json')
        end

        it 'matches the :expected_response' do
          get :show, params: params
          expect(json_response).not_to be_empty
          expect(json_response).to match(expected_response)
        end
      end

      context 'by #pid' do
        let!(:params) { { id: ark.pid, version: 'v2', format: :json } }

        it 'returns a successful json response' do
          get :show, params: params
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq('application/json')
        end

        it 'matches the :expected_response' do
          get :show, params: params
          expect(json_response).not_to be_empty
          expect(json_response).to match(expected_response)
        end
      end
    end

    context 'object_in_view' do
    end

    context '#not_found' do
      let!(:params) { { id: 'foo:b1a23r456', version: 'v2', format: :json } }

      let!(:expected_response) do
        {
          errors: [{
            title: 'Not Found',
            status: Rack::Utils.status_code(:not_found),
            message: '',
            detail: {
              pointer: 'api/v2/arks'
            }
          }]
        }.as_json
      end

      it 'returns a 404 json response' do
        get :show, params: params
        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to eq('application/json')
      end

      it 'matches the :expected_response' do
        get :show, params: params
        expect(json_response).not_to be_empty
        # awesome_print json_response
      end
    end
  end

  describe '#create' do
    context 'new ark' do
    end
    context 'existing ark' do
    end
    context 'restoring ark' do
    end
    context 'invalid ark' do
    end
  end

  describe '#destroy' do
    context 'successful' do
    end

    context 'unsuccessful' do
    end
  end
end
