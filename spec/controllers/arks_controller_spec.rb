# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArksController, type: :controller do
  let!(:default_valid_json_params) { { format: :json, version: 'v2' } }
  describe '#show' do
    let!(:ark) { create(:ark) }

    context 'json response' do
      render_views

      let!(:expected_response) { ark_as_json(ark) }

      context 'by #id' do
        let!(:params) { default_valid_json_params.dup.merge({ id: ark.id }) }

        specify 'correct template is used' do
          get :show, params: params
          expect(response).to render_template(:show)
        end

        it 'returns a successful json response' do
          get :show, params: params
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq('application/json')
          expect(json_response).not_to be_empty
        end

        it 'matches the :expected_response' do
          get :show, params: params
          expect(json_response).to have_key('ark')
          expect(json_response).to match(expected_response)
        end
      end

      context 'by #pid' do
        let!(:params) { default_valid_json_params.dup.merge({ id: ark.pid }) }

        it 'returns a successful json response' do
          get :show, params: params
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq('application/json')
          expect(json_response).not_to be_empty
        end

        it 'matches the :expected_response' do
          get :show, params: params
          expect(json_response).to have_key('ark')
          expect(json_response).to match(expected_response)
        end
      end
    end

    describe '#not_found' do
      let!(:params) { default_valid_json_params.dup.merge({ id: 'foo:b1a23r456' }) }

      let!(:expected_response) do
        {
          errors: [{
            title: 'Not found',
            status: Rack::Utils.status_code(:not_found),
            message: "can't find record with friendly id: \"#{params[:id]}\"",
            detail: {
              pointer: "/api/v2/arks/#{params[:id]}"
            }
          }]
        }.as_json
      end

      it 'returns a 404 json response' do
        get :show, params: params
        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to eq('application/json')
        expect(json_response).not_to be_empty
      end

      it 'matches the :expected_response' do
        get :show, params: params
        expect(json_response).to have_key('errors')
        expect(json_response).to match(expected_response)
      end
    end

    context 'object_in_view' do
      let!(:valid_params) { { ark: 'ark:', namespace: ark.namespace_ark, noid: ark.noid, object_in_view: true } }

      it 'expects a 302 response and to redirect_to the :ark #redirect_url' do
        get :show, params: valid_params
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(ark.redirect_url)
      end

      context 'with invalid params' do
        let(:invalid_params) { valid_params.dup.update(noid: 'abcde1234') }

        it 'expects a 404 response with no content' do
          get :show, params: invalid_params
          expect(response.content_type).to eq('text/html')
          expect(response).to have_http_status(:not_found)
          expect(response.body).to be_empty
        end
      end
    end
  end

  describe '#create' do
    render_views

    let!(:institution_ark) { create(:ark, :institution_ark) }
    let!(:collection_ark) { create(:ark, :collection_ark, parent_pid: institution_ark.pid) }
    let!(:object_ark) { create(:ark, :object_ark, parent_pid: collection_ark.pid) }
    let!(:input_fields) { %w(namespace_id namespace_ark parent_pid local_original_identifier local_original_identifier_type model_type url_base) }

    let(:deleted_object_ark) { create(:ark, :object_ark, parent_pid: collection_ark.pid, deleted: true) }
    let(:valid_ark_attributes) { FactoryBot.attributes_for(:ark, :object_ark, parent_pid: collection_ark.pid) }

    context 'new ark' do
      let!(:params) { default_valid_json_params.dup.merge({ ark: valid_ark_attributes }) }

      specify 'creates new ark' do
        expect do
          post :create, params: params
        end.to change(Ark, :count).by(1)
      end

      specify 'correct template rendered' do
        post :create, params: params
        expect(response).to render_template(:create)
      end

      it 'returns a 201(created) json_response' do
        post :create, params: params
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        expect(json_response).not_to be_empty
      end

      it 'expects the :input_fields to match the json_response' do
        post :create, params: params
        expect(json_response).to have_key('ark')
        input_fields.each do |attr_field|
          expect(json_response['ark'][attr_field]).to eq(valid_ark_attributes[attr_field.to_sym])
        end
      end
    end

    context 'existing ark' do
      let!(:params) { default_valid_json_params.dup.merge({ ark: object_ark.attributes.slice(*input_fields) }) }
      let!(:expected_response) { ark_as_json(object_ark) }

      specify 'correct template rendered' do
        post :create, params: params
        expect(response).to render_template(:show)
      end

      specify 'does not create new ark' do
        expect do
          post :create, params: params
        end.to change(Ark, :count).by(0)
      end

      it 'returns a 200(ok) json_response' do
        post :create, params: params
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
        expect(json_response).not_to be_empty
      end

      it 'expects the json_response to match the attributes in the :expected_response' do
        post :create, params: params
        expect(json_response).to have_key('ark')
        expect(json_response).to match(expected_response)
      end
    end

    context 'restoring ark' do
      let!(:params) { default_valid_json_params.dup.merge({ ark: deleted_object_ark.attributes.slice(*input_fields) }) }

      specify 'correct template rendered' do
        post :create, params: params
        expect(response).to render_template(:create)
      end

      specify 'increments the active count' do
        expect do
          post :create, params: params
        end.to change(Ark.active, :count).by(1)
      end

      it 'returns a 200(ok) json_response' do
        post :create, params: params
        expect(response).to have_http_status(:accepted)
        expect(response.content_type).to eq('application/json')
        expect(json_response).not_to be_empty
      end

      it 'expects the json_response to match the attributes in the :expected_response' do
        post :create, params: params
        expect(json_response).to have_key('ark')
        expect(json_response).to match(ark_as_json(deleted_object_ark.reload))
      end
    end

    context 'invalid ark' do
      let!(:invalid_params) do
        ark_params = valid_ark_attributes.dup
        input_fields.each do |field|
          ark_params.update(field.to_sym => nil)
        end
        ark_params
      end

      let!(:params) { default_valid_json_params.dup.merge(ark: invalid_params) }
      let!(:expected_response) { all_ark_errors }

      specify 'correct template rendered' do
        post :create, params: params
        expect(response).to render_template(:create)
      end

      specify 'does not create new ark' do
        expect do
          post :create, params: params
        end.to change(Ark, :count).by(0)
      end

      it 'returns a 422(unprocessible_entity) json_response' do
        post :create, params: params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
        expect(json_response).not_to be_empty
      end

      it 'expects the json_response to match the attributes in the :expected_response' do
        post :create, params: params
        expect(json_response).to have_key('errors')
        expect(json_response).to match(expected_response)
      end
    end
  end

  describe '#destroy' do
    let(:deleted_ark) { create(:ark, deleted: true) }
    let(:ark) { create(:ark) }
    let(:valid_params) { default_valid_json_params.dup.merge(id: ark.id) }
    let(:valid_pid_params) { default_valid_json_params.dup.merge(id: ark.pid) }
    let(:invalid_params) { default_valid_json_params.dup.merge(id: deleted_ark.id) }

    context 'successful' do
      context 'by #id' do
        specify 'existing ark should be deleted' do
          delete :destroy, params: valid_params
          expect(ark.reload.deleted).to be_truthy
          expect { Ark.active.find(ark.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it 'returns a 204(no_content) response with an empty body' do
          delete :destroy, params: valid_params
          expect(response).to have_http_status(:no_content)
          expect(response.body).to be_empty
        end
      end

      context 'by #pid' do
        specify 'ark should be deleted' do
          delete :destroy, params: valid_pid_params
          expect(ark.reload.deleted).to be_truthy
          expect { Ark.active.find(ark.pid) }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it 'returns a 204(no_content) response with an empty body' do
          delete :destroy, params: valid_pid_params
          expect(response).to have_http_status(:no_content)
          expect(response.body).to be_empty
        end
      end
    end

    context 'unsuccessful' do
      let(:expected_response) do
        {
          errors: [{
            title: 'Not found',
            status: Rack::Utils.status_code(:not_found),
            message: "Couldn't find Ark with 'id'=#{invalid_params[:id]} [WHERE \"arks\".\"deleted\" = $1]",
            detail: {
              pointer: "/api/v2/arks/#{invalid_params[:id]}"
            }
          }]
        }.as_json
      end

      it 'returns a 404(not_found) json_response' do
        # If the ark is already deleted it should return a 404
        delete :destroy, params: invalid_params
        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to eq('application/json')
        expect(json_response).not_to be_empty
      end

      it 'expects the json_response to match the :expected_response' do
        delete :destroy, params: invalid_params
        expect(json_response).to have_key('errors')
        expect(json_response).to match(expected_response)
      end
    end
  end
end
