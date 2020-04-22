# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/service_class'

RSpec.describe ApplicationService, type: :service do
  subject { described_class }

  specify { is_expected.to respond_to(:inherited).with(1).argument }

  describe '#inherited' do
    let!(:described_service_class) do
      Class.new(described_class) do
        def call
          'I Have been Called!'
        end
      end
    end

    specify { expect(described_service_class).to be_const_defined('ActiveModel::Validations') }
    specify { expect(described_service_class).to respond_to(:call).with_unlimited_arguments }

    it_behaves_like 'service_class' do
      let(:described_service_class_instance) { described_service_class.new }
    end

    describe 'successful #result' do
      subject { described_service_class.call }

      it { is_expected.to be_success.and be_successful }
      it { is_expected.not_to be_failure }

      it 'expects the #errors to be #empty?' do
        expect(subject.errors).to be_empty
      end

      it 'Expects the #result to have the correct value' do
        expect(subject.result).to eq('I Have been Called!')
      end
    end

    describe 'deliberate failure' do
      subject { failure_class.call }

      let(:failure_class) do
        Class.new(described_class) do
          def call
            errors.add(:base, 'deliberate failure')
            nil
          end
        end
      end

      it { is_expected.not_to be_success }
      it { is_expected.not_to be_successful }
      it { is_expected.to be_failure }

      it 'expects the #errors not to be #empty?' do
        expect(subject.errors).not_to be_empty
        expect(subject.errors.full_messages).to include('deliberate failure')
      end

      it 'expects the #result to be nil' do
        expect(subject.result).to be_nil
      end
    end
  end
end
