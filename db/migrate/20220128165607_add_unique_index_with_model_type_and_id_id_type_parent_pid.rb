# frozen_string_literal: true

class AddUniqueIndexWithModelTypeAndIdIdTypeParentPid < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def up
    add_index :arks, [:local_original_identifier, :local_original_identifier_type, :model_type], where: 'parent_pid IS NULL', unique: true, using: :btree, algorithm: :concurrently, name: 'unique_local_id_local_id_type_model_type_parent_null' if !index_name_exists?(:arks, 'unique_local_id_local_id_type_model_type_parent_null')
    add_index :arks, [:local_original_identifier, :local_original_identifier_type, :model_type, :parent_pid], where: 'parent_pid IS NOT NULL', unique: true, using: :btree, algorithm: :concurrently, name: 'unique_local_id_local_id_type_model_type_parent_not_null' if !index_name_exists?(:arks, 'unique_local_id_local_id_type_model_type_parent_not_null')
  end

  def down
    remove_index :arks, name: 'unique_local_id_local_id_type_model_type_parent_null', algorithm: :concurrently if index_name_exists?(:arks, 'unique_local_id_local_id_type_model_type_parent_null')
    remove_index :arks, name: 'unique_local_id_local_id_type_model_type_parent_not_null', algorithm: :concurrently if index_name_exists?(:arks, 'unique_local_id_local_id_type_model_type_parent_not_null')
  end
end
