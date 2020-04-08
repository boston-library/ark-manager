# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ark, type: :model do
  let!(:ark_attributes) do
    {
      namespace_ark: '50959',
      namespace_id: 'bpl-dev',
      local_original_identifier: 'Foo-bar-0001.tif',
      local_original_identifier_type: 'filename',
      model_type: 'Bplmodels::PhotographicPrint',
      url_base: 'https://search-hydradev.bpl.org'
    }
  end

  describe 'Database' do
    describe 'Columns' do
      it { is_expected.to have_db_column(:namespace_ark).of_type(:string).with_options(null: false) }

      it { is_expected.to have_db_column(:namespace_ark).of_type(:string).with_options(null: false) }

      it { is_expected.to have_db_column(:url_base).of_type(:string).with_options(null: false) }

      it { is_expected.to have_db_column(:namespace_id).of_type(:string).with_options(null: false) }

      it { is_expected.to have_db_column(:namespace_ark).of_type(:string).with_options(null: false) }

      it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }

      it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

      it { is_expected.to have_db_column(:parent_pid).of_type(:string) }

      it { is_expected.to have_db_column(:deleted).of_type(:boolean).with_options(default: false) }

      it { is_expected.to have_db_column(:secondary_parent_pids).of_type(:string).with_options(default: [], array: true) }

      it { is_expected.to have_db_column(:pid).of_type(:string).with_options(null: false) }
    end

    describe 'Indexes' do
      it { is_expected.to have_db_index(:noid).unique(true) }

      it { is_expected.to have_db_index(:pid).unique(true) }

      it { is_expected.to have_db_index([:local_original_identifier, :local_original_identifier_type]) }

      it { is_expected.to have_db_index([:namespace_ark, :noid]) }

      it { is_expected.to have_db_index(:created_at) }

      it { is_expected.to have_db_index(:deleted) }

      it { is_expected.to have_db_index(:parent_pid) }

      it { is_expected.to have_db_index(:secondary_parent_pids) }

    end
  end

  describe 'Scopes' do
    let!(:namespace_ark) { 'bpl-dev' }
    let!(:parent_id) { "#{namespace_ark}:3214dde845" }
    let!(:identifier) { 'Foo-Bar-002.tif' }
    let!(:identifier_type) { 'filename' }
    let!(:noid) { '644529e066' }

    specify { expect(described_class).to respond_to(:active) }
    specify { expect(described_class).to respond_to(:with_parent).with(1).argument }
    specify { expect(described_class).to respond_to(:with_local_id, :object_in_view).with(2).arguments }
    specify { expect(described_class).to respond_to(:with_parent_and_local_id).with(3).arguments }

    describe '#default_scope' do
      subject { described_class.all.to_sql }

      let!(:expected_sql) { described_class.unscoped.order(created_at: :desc).to_sql }

      it { is_expected.to eq(expected_sql) }
    end

    describe '#active' do
      subject { described_class.active.to_sql }

      let!(:expected_sql) { described_class.where(deleted: false).to_sql }

      it { is_expected.to eq(expected_sql) }
    end

    describe '#with_parent' do
      subject { described_class.with_parent(parent_id).to_sql }

      let!(:expected_sql) { described_class.where(parent_pid: parent_id).to_sql }

      it { is_expected.to eq(expected_sql) }
    end

    describe '#with_local_id' do
      subject { described_class.with_local_id(identifier, identifier_type).to_sql }

      let!(:expected_sql) { described_class.where(local_original_identifier: identifier, local_original_identifier_type: identifier_type).to_sql }

      it { is_expected.to eq(expected_sql) }
    end

    describe '#with_parent_and_local_id' do
      subject { described_class.with_parent_and_local_id(parent_id, identifier, identifier_type).to_sql }

      let!(:expected_sql) { described_class.with_parent(parent_id).merge(described_class.with_local_id( identifier, identifier_type)).to_sql }

      it { is_expected.to eq(expected_sql) }
    end

    describe '#object_in_view' do
    end
  end

  describe 'Validations' do
    subject { described_class.create(ark_attributes) }

    it { is_expected.to validate_presence_of(:namespace_ark) }
    it { is_expected.to validate_presence_of(:namespace_id) }
    it { is_expected.to validate_presence_of(:model_type) }
    it { is_expected.to validate_presence_of(:local_original_identifier) }
    it { is_expected.to validate_presence_of(:local_original_identifier_type) }
    it { is_expected.to validate_presence_of(:noid) }
    it { is_expected.to validate_presence_of(:url_base) }

    it { is_expected.to validate_uniqueness_of(:noid).case_insensitive }
  end

  describe 'Callbacks' do
    let!(:ark_attributes_2) { ark_attributes.dup.update({ local_original_identifier: 'Foo-Bar-0002.tif' }) }
    let!(:new_ark_instance) { described_class.new(ark_attributes_2) }

    describe '#before_validation' do
      subject { new_ark_instance }

      it 'sets the #noid #before_validation' do
        expect(subject.noid).to be_falsey
        subject.valid?
        expect(subject.noid).to be_truthy
      end
    end

    describe '#friendly_id callbacks' do
      subject do
        new_ark_instance.save!
        new_ark_instance.reload
      end

      let!(:expected_pid) { "#{subject.namespace_id}:#{subject.noid}" }

      it 'sets the pid on when the new ark is saved' do
        expect(subject).to be_valid
        expect(subject.pid).to be_truthy.and eql(expected_pid)
      end
    end
  end

  describe 'Methods' do
    let!(:ark_attributes_3) { ark_attributes.dup.update({ local_original_identifier: 'Foo-Bar-0003.tif' }) }
    let!(:ark_instance){ described_class.create!(ark_attributes_3) }

    describe '#to_s' do
      subject { ark_instance }

      let!(:expected_output) { Oj.dump(ark_instance.as_json, indent: 2) }

      it 'expects the :expected_output to macth the output of the method call' do
        expect(subject.to_s).to match(expected_output)
      end
    end

    describe '#redirect_url' do
      subject { ark_instance }

      let!(:expected_output) { "#{ark_instance.url_base}/search/#{ark_instance.pid}" }

      it 'expects the :expected_output to macth the output of the method call' do
        expect(subject.redirect_url).to eql(expected_output)
      end
    end
  end
end
