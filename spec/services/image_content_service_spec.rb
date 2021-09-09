# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/service_class'

RSpec.describe ImageContentService, type: :service do
  let(:described_service_class) { described_class }
  let(:valid_ark_id) { 'bpl-dev:j6731q74d' }
  let(:filestream_attachment_name) { 'image_thumbnail_300' }
  let(:filestream_key) { 'images/bpl-dev:j6731q75p' }
  let(:file_suffix) {  '_thumbnail' }

  specify { expect(described_service_class).to be_const_defined('ApplicationService') }
  specify { expect(described_service_class).to be_const_defined('IMG_DEST_FOLDER') }
  specify { expect(described_service_class).to respond_to(:call).with(3).arguments }

  it_behaves_like 'service_class' do
    let(:class_call_args) { [filestream_attachment_name, filestream_key, file_suffix] }
    let(:described_service_class_instance) { described_service_class.new(filestream_attachment_name, filestream_key, file_suffix) }

    around(:each) { |spec| VCR.use_cassette("services/image_content/#{valid_ark_id}", &spec) }
  end

  describe 'instance' do
    subject { described_service_class.new(filestream_attachment_name, filestream_key, file_suffix) }

    it { is_expected.to respond_to(:filestream_attachment_name, :filestream_key, :file_suffix, :filestream_ark_id, :destination_path) }
  end

  describe 'successful #result' do
    subject { described_service_class.call(filestream_attachment_name, filestream_key, file_suffix) }

    around(:each) { |spec| VCR.use_cassette("services/image_content/#{valid_ark_id}", &spec) }

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
    subject { described_service_class.call(filestream_attachment_name, filestream_key, file_suffix) }

    let(:invalid_ark_id) { 'bpl-dev:nonexistent' }
    let(:filestream_id) { 'image_thumbnail_300' }
    let(:filestream_key) { "images/#{invalid_ark_id}" }
    let(:file_suffix) {  '_thumbnail' }

    around(:each) { |spec| VCR.use_cassette("services/image_content/#{invalid_ark_id}", &spec) }

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
