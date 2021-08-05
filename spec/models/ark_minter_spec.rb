# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArkMinter, type: :model do
  describe 'Class' do
    subject { described_class }

    it { is_expected.to be <= Noid::Rails::Minter::Db }
  end

  describe 'Instance' do
    subject { described_class.new }

    it { is_expected.to respond_to(:namespace, :template, :default_namespace, :mint, :read) }
    it { is_expected.to respond_to(:write!).with(1).argument }

    it 'expects the default namespace to equal the config namespace' do
      expect(subject.default_namespace).to eq(Noid::Rails.config.namespace)
    end

    it 'expects to #mint to produce a string' do
      expect(subject.mint).to be_a_kind_of(String)
    end
  end
end
