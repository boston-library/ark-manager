class AddSecondaryParentPidsToArks < ActiveRecord::Migration
  def change
    remove_column :arks, :secondary_parent_pids
    add_column :arks, :secondary_parent_pids, :string, array: true, default: '{}'
  end
end