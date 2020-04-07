# frozen_string_literal: true

class AddLocalIdentifierToArks < ActiveRecord::Migration[5.2]
  def change
    add_column :arks, :local_original_identifier, :string
    add_column :arks, :local_original_identifier_type, :string
  end
end
