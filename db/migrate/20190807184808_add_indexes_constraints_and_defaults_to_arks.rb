# frozen_string_literal: true

class AddIndexesConstraintsAndDefaultsToArks < ActiveRecord::Migration[5.2]
  def change
    change_column_null :arks, :created_at, false
    change_column_null :arks, :updated_at, false
    change_column_null :arks, :url_base, false
    change_column_null :arks, :namespace_ark, false
    change_column_null :arks, :namespace_id, false
    change_column_null :arks, :noid, false
    change_column_null :arks, :local_original_identifier, false
    change_column_null :arks, :local_original_identifier_type, false
    change_column_null :arks, :model_type, false
    change_column_default :arks, :deleted, false

    Ark.transaction do
      Ark.where(deleted: nil).update_all(deleted: false)
    end

    add_index :arks, :noid, unique: true, using: :btree
    add_index :arks, [:local_original_identifier, :local_original_identifier_type], using: :btree, name: 'index_arks_localid'
    add_index :arks, :parent_pid, where: 'parent_pid is not null', using: :btree
    add_index :arks, [:namespace_ark, :noid], using: :btree
    add_index :arks, :deleted, where: 'deleted = false', using: :btree
    add_index :arks, :secondary_parent_pids, using: :gin
    add_index :arks, :created_at, order: { created_at: :desc }
  end
end
