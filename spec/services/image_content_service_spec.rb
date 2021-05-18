# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/service_class'

RSpec.describe ImageContentService, type: :service do
  let(:described_service_class) { described_class }
  let(:valid_ark_id) { 'bpl-dev:j6731q74d' }
  let(:filestream_id) { 'image_thumbnail_300' }
  let(:filestream_key) { 'images/bpl-dev:j6731q75p' }
  let(:file_suffix) {  '_thumbnail' }

  specify { expect(described_service_class).to be_const_defined('ApplicationService') }
  specify { expect(described_service_class).to respond_to(:call).with(4).arguments }

  it_behaves_like 'service_class' do
    let(:class_call_args) { [valid_ark_id, filestream_id, filestream_key, file_suffix] }
    let(:described_service_class_instance) { described_service_class.new(valid_ark_id, filestream_id, filestream_key, file_suffix) }

    around(:each) { |spec| VCR.use_cassette("services/image_content/#{valid_ark_id}", &spec) }
  end

  describe 'successful #result' do
    subject { described_service_class.call(valid_ark_id, filestream_id, filestream_key, file_suffix) }

    around(:each) { |spec| VCR.use_cassette("services/image_content/#{valid_ark_id}", &spec) }

    it { is_expected.to be_success.and be_successful }
    it { is_expected.not_to be_failure }

    it 'expects the #errors to be #empty?' do
      expect(subject.errors).to be_empty
    end

    it 'Expects the #result to have the correct value' do
      expect(subject.result).to be_a_kind_of(Tempfile)
    end
  end

  describe 'deliberate failure' do
  end
end
