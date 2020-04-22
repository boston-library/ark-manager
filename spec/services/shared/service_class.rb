# frozen_string_literal: true

RSpec.shared_examples 'service_class', type: :service do
  specify { expect(described_service_class).to be_truthy }
  specify { expect(described_service_class_instance).to be_truthy }

  describe 'ClassMethods' do
    subject { described_service_class }

    it { is_expected.to be_const_defined(:ServiceClass) }
    it { is_expected.to respond_to(:call) }

    describe '.call' do
      subject { described_service_class.call }

      before(:each) { allow(described_service_class).to receive(:call).and_call_original }

      it { is_expected.to be_an_instance_of(described_service_class) }
    end
  end

  describe 'InstanceMethods' do
    subject { described_service_class_instance }

    it { is_expected.to respond_to(:call, :result, :success?, :successful?, :failure?, :errors) }

    describe 'Base Properties' do
      it 'expects #result to be nil' do
        expect(subject.result).to be_nil
      end

      it 'expects #called? #success? #successful? #failure? to all return false' do
        %i(called? success? successful? failure?).each do |inst_method|
          expect(subject.send(inst_method)).to be_falsey
        end
      end
    end

    describe 'After #call Properties' do
      subject { described_service_class_instance.call }

      it 'expects #result to be truthy' do
        expect(subject.result).to be_truthy
      end

      it 'expects #called? #success? #successful to all return true' do
        %i(called? success? successful?).each do |inst_method|
          expect(subject.send(inst_method)).to be_truthy
        end
      end
    end
  end
end
