# frozen_string_literal: true

class AddSlugToArks < ActiveRecord::Migration[5.2]
  def change
    # NOTE: pid is the slug referenced in friendly_id
    add_column :arks, :pid, :string, null: false
    add_index :arks, :pid, unique: true, using: :btree

    Ark.reset_column_information

    Ark.transaction do
      Ark.find_each(&:save!)
    end
  end
end
