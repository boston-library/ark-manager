class AddParentIdToArks < ActiveRecord::Migration
  def change
    add_column :arks, :parent_pid, :string
  end
end