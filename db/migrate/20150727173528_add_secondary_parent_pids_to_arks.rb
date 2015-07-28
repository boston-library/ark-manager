class AddSecondaryParentPidsToArks < ActiveRecord::Migration
  def change
    add_column :arks, :secondary_parent_pids, :string, array: true, default: []
  end
end