# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/service_class'

RSpec.describe SolrService, type: :service do
  let(:valid_ark_id) { 'bpl-dev:j6731q74d' }
  let(:described_service_class) { described_class }

  specify { expect(described_service_class).to be_const_defined('ApplicationService') }
  specify { expect(described_service_class).to respond_to(:call).with(1).arguments }

  it_behaves_like 'service_class' do
    let(:class_call_args) { Array.wrap(valid_ark_id) }
    let(:described_service_class_instance) { described_service_class.new(valid_ark_id) }

    around(:each) { |spec| VCR.use_cassette("services/solr/#{valid_ark_id}", serialize_with: :json, &spec) }
  end

  describe '.solr_client' do
    subject { described_service_class }

    it { is_expected.to respond_to(:solr_client) }

    it 'is expected to be an instance of RSolr::Client' do
      expect(subject.solr_client).to be_an_instance_of(RSolr::Client)
      expect(subject.solr_client.object_id).to eq(Thread.current[:current_curator_solr_client].object_id)
    end

    it 'expects the .solr_client to have the correct url set' do
      expect(subject.solr_client.options).to have_key(:url)
      expect(subject.solr_client.options[:url]).to eq(ENV['CURATOR_SOLR_URL'])
    end
  end

  describe '#query' do
    subject { described_service_class.new(valid_ark_id) }

    let(:expected_query) { { 'id': valid_ark_id } }

    it { is_expected.to respond_to(:query) }

    it 'is expected to match the query value' do
      expect(subject.query).to match(expected_query)
    end
  end

  describe '#explicit' do
    subject { described_service_class.new(valid_ark_id) }

    it { is_expected.to respond_to(:explicit?) }
  end

  describe 'successful #result' do
    subject { described_service_class.call(valid_ark_id) }

    around(:each) { |spec| VCR.use_cassette("services/solr/#{valid_ark_id}", serialize_with: :json, &spec) }

    let(:expected_solr_doc_keys) { %w(id exemplary_image_key_base_ss) }

    it { is_expected.to be_success.and be_successful }
    it { is_expected.not_to be_failure }

    it 'expects the #errors to be #empty?' do
      expect(subject.errors).to be_empty
    end

    it 'Expects the #result to have the correct value' do
      expect(subject.result).to be_a_kind_of(Hash)
      expected_solr_doc_keys.each do |expected_solr_doc_key|
        expect(subject.result).to have_key(expected_solr_doc_key), "#{expected_solr_doc_key} was not in subject"
      end
      expect(subject.result['id']).to eq(valid_ark_id)
    end
  end

  describe 'deliberate failure' do
    subject { described_service_class.call(invalid_ark_id) }

    let(:invalid_ark_id) { 'bpl-dev:nonexistent' }

    around(:each) { |spec| VCR.use_cassette("services/solr/#{invalid_ark_id}", serialize_with: :json, &spec) }

    it { is_expected.not_to be_success }
    it { is_expected.not_to be_successful }
    it { is_expected.to be_failure }

    it 'expects the #errors not to be #empty?' do
      expect(subject.errors).not_to be_empty
      expect(subject.errors.messages).to have_key(:not_found)
    end

    it 'expects the #result to be an empty Hash' do
      expect(subject.result).to be_a_kind_of(Hash).and be_empty
    end
  end
end
