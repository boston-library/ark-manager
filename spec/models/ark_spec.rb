# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ark, type: :model do
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

      it { is_expected.to have_db_index(:deleted) }

      it { is_expected.to have_db_index(:parent_pid) }

      it { is_expected.to have_db_index(:secondary_parent_pids) }
    end
  end

  describe 'Scopes' do
  end

  describe 'Validations' do
  end

  describe 'Methods' do
  end
end
