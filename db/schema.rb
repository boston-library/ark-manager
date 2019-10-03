# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_08_12_132958) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "arks", force: :cascade do |t|
    t.string "namespace_ark", null: false
    t.string "url_base", null: false
    t.string "noid", null: false
    t.string "namespace_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "model_type", null: false
    t.string "local_original_identifier", null: false
    t.string "local_original_identifier_type", null: false
    t.string "parent_pid"
    t.boolean "deleted", default: false
    t.string "secondary_parent_pids", default: [], array: true
    t.index ["deleted"], name: "index_arks_on_deleted"
    t.index ["local_original_identifier", "local_original_identifier_type"], name: "index_arks_localid"
    t.index ["noid"], name: "index_arks_on_noid", unique: true
    t.index ["parent_pid"], name: "index_arks_on_parent_pid"
    t.index ["secondary_parent_pids"], name: "index_arks_on_secondary_parent_pids", using: :gin
  end

end
