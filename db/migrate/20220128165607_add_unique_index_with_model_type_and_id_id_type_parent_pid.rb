# frozen_string_literal: true

class AddUniqueIndexWithModelTypeAndIdIdTypeParentPid < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def up
    check_and_destroy_duplicate_arks! if Rails.env.development?
    add_index :arks, [:local_original_identifier, :local_original_identifier_type, :model_type], where: 'parent_pid IS NULL', unique: true, using: :btree, algorithm: :concurrently, name: 'unique_local_id_local_id_type_model_type_parent_null' if !index_name_exists?(:arks, 'unique_local_id_local_id_type_model_type_parent_null')
    add_index :arks, [:local_original_identifier, :local_original_identifier_type, :model_type, :parent_pid], where: 'parent_pid IS NOT NULL', unique: true, using: :btree, algorithm: :concurrently, name: 'unique_local_id_local_id_type_model_type_parent_not_null' if !index_name_exists?(:arks, 'unique_local_id_local_id_type_model_type_parent_not_null')
  end

  def down
    remove_index :arks, name: 'unique_local_id_local_id_type_model_type_parent_null', algorithm: :concurrently if index_name_exists?(:arks, 'unique_local_id_local_id_type_model_type_parent_null')
    remove_index :arks, name: 'unique_local_id_local_id_type_model_type_parent_not_null', algorithm: :concurrently if index_name_exists?(:arks, 'unique_local_id_local_id_type_model_type_parent_not_null')
  end

  protected

  def check_and_destroy_duplicate_arks!
    dupes_without_parent = Ark.unscoped.select(:local_original_identifier, :local_original_identifier_type, :model_type).without_parent.group(:local_original_identifier, :local_original_identifier_type, :model_type).having('count(*) > 1')
    dupes_with_parent = Ark.unscoped.select(:local_original_identifier, :local_original_identifier_type, :model_type, :parent_pid).where('parent_pid IS NOT NULL').group(:local_original_identifier, :local_original_identifier_type, :model_type, :parent_pid).having('count(*) > 1')

    return if dupes_without_parent.blank? && dupes_with_parent.blank?

    # rubocop:disable Style/GuardClause
    if dupes_without_parent.present?
      say_with_time 'Removing Duplicates without parent by least recently updated' do
        remove_duplicate_group(dupes_without_parent)
      end
    end

    if dupes_with_parent.present?
      say_with_time 'Removing Duplicates with parent by least recently updated' do
        remove_duplicate_group(dupes_with_parent)
      end
    end
    # rubocop:enable Style/GuardClause
  end

  private

  def remove_duplicate_group(dupes)
    dupe_attrs_group = dupes.map { |d| d.attributes.except('id') }
    dupe_attrs_group.each do |dupe_attrs|
      Ark.transaction do
        duplicate_group = Ark.unscoped.where(dupe_attrs).order(updated_at: :asc)
        dupes_to_destroy = duplicate_group.where.not(id: duplicate_group.last.id)
        dupes_to_destroy.destroy_all
      end
    end
  end
end
