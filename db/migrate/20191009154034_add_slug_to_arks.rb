class AddSlugToArks < ActiveRecord::Migration[5.2]
  def change
    add_column :arks, :pid, :string, null: false #pid is the slug referenced in Friednly ID
    add_index :arks, :pid, unique: true, using: :btree

    Ark.reset_column_information

    Ark.transaction do
      Ark.find_each(&:save!)
    end

  end
end
