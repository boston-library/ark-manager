class AddTypeToArk < ActiveRecord::Migration[5.2]
  def change
    add_column :arks, :model_type, :string
  end
end
