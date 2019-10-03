class AddParentIdToArks < ActiveRecord::Migration[5.2]
  def change
    add_column :arks, :parent_pid, :string
  end
end
