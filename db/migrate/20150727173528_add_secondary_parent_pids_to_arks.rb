class AddSecondaryParentPidsToArks < ActiveRecord::Migration[5.2]
  def change
    add_column :arks, :secondary_parent_pids, :string, array: true, default: []
  end
end
