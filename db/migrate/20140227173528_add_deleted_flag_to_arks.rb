# frozen_string_literal: true

class AddDeletedFlagToArks < ActiveRecord::Migration[5.2]
  def change
    add_column :arks, :deleted, :boolean
  end
end
