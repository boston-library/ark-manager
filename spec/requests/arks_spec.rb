# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Arks', type: :request do
  describe 'GET /arks' do
    skip 'works! (now write some real specs)' do
      get arks_path
      expect(response).to have_http_status(200)
    end
  end
end
