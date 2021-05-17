# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/service_class'

RSpec.describe SolrService, type: :service do
  let(:ark_id) { 'bpl-dev:j6731q74d' }
  let(:described_service_class) { described_class }

  specify { expect(described_service_class).to be_const_defined('ApplicationService') }
  specify { expect(described_service_class).to respond_to(:call).with(1).arguments }

  it_behaves_like 'service_class' do
    around(:each) do |spec|
      VCR.use_cassette("services/solr/#{ark_id}", &spec)
    end

    let(:described_service_class_instance) { described_service_class.new(ark_id) }
  end
end
