# frozen_string_literal: true

class FixSecondaryParentPidsToArks < ActiveRecord::Migration[5.2]
  def change
    remove_column :arks, :secondary_parent_pids
    add_column :arks, :secondary_parent_pids, :string, array: true, default: '{}'
  end
end
