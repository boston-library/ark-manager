class AddTypeToArk < ActiveRecord::Migration
  def change
    add_column :arks, :model_type, :string
  end
end
