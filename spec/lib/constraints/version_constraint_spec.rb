# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/route_constraint'

RSpec.describe VersionConstraint, type: :constraint do
  subject { described_class }

  let!(:current_api_version) { 'v2' }

  it { is_expected.to be_const_defined(:ARK_VERSION) }

  specify ':ARK_VERSION to eq :current_api_version' do
    expect(subject.const_get(:ARK_VERSION)).to eq(current_api_version)
  end

  it_behaves_like 'route_constraint', is_instance: false

  describe '#matches' do
    let!(:valid_param) { double(params: { version: current_api_version }) }
    let!(:invalid_param) { double(params: { version: 'invalid_ver' }) }

    it { is_expected.to be_matches(valid_param) }
    it { is_expected.not_to be_matches(invalid_param) }
  end
end
