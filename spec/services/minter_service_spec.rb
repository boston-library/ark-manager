# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/service_class'

RSpec.describe MinterService, type: :service do
  let(:described_service_class) { described_class }
  let(:noid_regex) { /[a-z0-9]{9}/ }

  specify { expect(described_service_class).to be_const_defined('ApplicationService') }
  specify { expect(described_service_class).to respond_to(:call).with(0..1).arguments }

  it_behaves_like 'service_class' do
    let(:described_service_class_instance) { described_service_class.new }
  end

  describe '#minter' do
    subject { described_class.new }

    it { is_expected.to respond_to(:minter) }

    it 'expects the minter to be a ArkMinter' do
      expect(subject.minter).to be_an_instance_of(ArkMinter)
    end
  end

  describe 'successful #result' do
    subject { described_service_class.call }

    it { is_expected.to be_success.and be_successful }
    it { is_expected.not_to be_failure }

    it 'expects the #errors to be #empty?' do
      expect(subject.errors).to be_empty
    end

    it 'Expects the #result to have the correct value' do
      expect(subject.result).to match(noid_regex)
    end
  end

  describe 'deliberate failure' do
    context 'empty namespace arg causes failure' do
      subject { described_service_class.call('') }

      it { is_expected.not_to be_success }
      it { is_expected.not_to be_successful }
      it { is_expected.to be_failure }

      it 'expects the #errors not to be #empty?' do
        expect(subject.errors).not_to be_empty
      end

      it 'expects the #result to be nil' do
        expect(subject.result).to be_nil
      end
    end
  end
end
