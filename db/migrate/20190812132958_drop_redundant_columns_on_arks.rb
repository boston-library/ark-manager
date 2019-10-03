class DropRedundantColumnsOnArks < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        remove_column :arks, :pid
        remove_column :arks, :view_thumbnail
        remove_column :arks, :view_object
      end

      dir.down do
        add_column :arks, :pid, :string
        add_column :arks, :view_object, :string
        add_column :arks, :view_thumbnail, :string
      end
    end
  end
end
