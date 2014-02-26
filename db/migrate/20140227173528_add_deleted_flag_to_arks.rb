class AddDeletedFlagToArks < ActiveRecord::Migration
  def change
    add_column :arks, :deleted, :boolean
  end
end