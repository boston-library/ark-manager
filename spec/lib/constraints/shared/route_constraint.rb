# frozen_string_literal: true

RSpec.shared_examples 'route_constraint' do |is_instance: true|
  describe 'instance_of :decribed_class', if: is_instance do
    specify { expect(subject).to be_an_instance_of(described_class) }
  end

  it { is_expected.to respond_to(:matches?).with(1).argument }
end
