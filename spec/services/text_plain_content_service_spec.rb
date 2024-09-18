# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/service_class'

RSpec.describe TextPlainContentService do
  let(:described_service_class) { described_class }
  let(:valid_ark_id) { 'bpl-dev:8c97kq405'}
  let(:valid_filestream_key) { "texts/#{valid_ark_id}" }

  specify { expect(described_service_class).to be_const_defined('ApplicationService') }
  specify { expect(described_service_class).to respond_to(:new, :call).with(1).argument }

  it_behaves_like 'service_class' do
    let(:class_call_args) { Array.wrap(valid_filestream_key) }
    let(:described_service_class_instance) { described_class.new(valid_filestream_key) }

    around(:each) { |spec| VCR.use_cassette("services/text_plain_content/#{valid_ark_id}", &spec) }
  end

  describe 'instance' do
    subject { described_service_class.new(valid_filestream_key) }

    it { is_expected.to respond_to(:filestream_key) }
  end

  describe 'successful #result' do
    subject { described_service_class.call(valid_filestream_key) }

    around(:each) { |spec| VCR.use_cassette("services/text_plain_content/#{valid_ark_id}", &spec) }

    it { is_expected.to be_success.and be_successful }
    it { is_expected.not_to be_failure }

    it 'expects the #errors to be #empty?' do
      expect(subject.errors).to be_empty
    end

    it 'Expects the #result to have the correct value' do
      expect(subject.result).to be_a_kind_of(String)
    end
  end

  describe 'deliberate failure' do
    subject { described_service_class.call(invalid_filestream_key) }

    let(:invalid_ark_id) { 'bpl-dev:nonexistent' }
    let(:invalid_filestream_key) { "texts/#{invalid_ark_id}" }

    around(:each) { |spec| VCR.use_cassette("services/text_plain_content/#{invalid_ark_id}", &spec) }

    it { is_expected.not_to be_success }
    it { is_expected.not_to be_successful }
    it { is_expected.to be_failure }

    it 'expects the #errors not to be #empty?' do
      expect(subject.errors).not_to be_empty
      expect(subject.errors.messages).to have_key(:not_found)
    end

    it 'expects the #result to be an empty Hash' do
      expect(subject.result).to be_nil
    end
  end
end