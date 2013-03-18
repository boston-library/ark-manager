class AddLocalIdentifierToArks < ActiveRecord::Migration
  def change
    add_column :arks, :local_original_identifier, :string
    add_column :arks, :local_original_identifier_type, :string
  end
end
