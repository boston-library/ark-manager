class CreateArks < ActiveRecord::Migration
  def change
    create_table :arks do |t|
      t.string :namespace_ark
      t.string :url_base
      t.string :pid
      t.string :view_thumbnail
      t.string :view_object
      t.string :noid
      t.string :namespace_id

      t.timestamps
    end
  end
end
