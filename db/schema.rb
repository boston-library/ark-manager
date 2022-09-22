# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_01_28_165607) do

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
    t.string "pid", null: false
    t.index ["created_at"], name: "index_arks_on_created_at", order: :desc
    t.index ["deleted"], name: "index_arks_on_deleted", where: "(deleted = false)"
    t.index ["local_original_identifier", "local_original_identifier_type", "model_type", "parent_pid"], name: "unique_local_id_local_id_type_model_type_parent_not_null", unique: true, where: "(parent_pid IS NOT NULL)"
    t.index ["local_original_identifier", "local_original_identifier_type", "model_type"], name: "unique_local_id_local_id_type_model_type_parent_null", unique: true, where: "(parent_pid IS NULL)"
    t.index ["local_original_identifier", "local_original_identifier_type"], name: "index_arks_localid"
    t.index ["namespace_ark", "noid"], name: "index_arks_on_namespace_ark_and_noid"
    t.index ["noid"], name: "index_arks_on_noid", unique: true
    t.index ["parent_pid"], name: "index_arks_on_parent_pid", where: "(parent_pid IS NOT NULL)"
    t.index ["pid"], name: "index_arks_on_pid", unique: true
    t.index ["secondary_parent_pids"], name: "index_arks_on_secondary_parent_pids", using: :gin
  end

  create_table "minter_states", id: :serial, force: :cascade do |t|
    t.string "namespace", default: "default", null: false
    t.string "template", null: false
    t.json "counters"
    t.bigint "seq", default: 0
    t.binary "rand"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["namespace", "template"], name: "index_minter_states_on_namespace_and_template"
    t.index ["namespace"], name: "index_minter_states_on_namespace", unique: true
  end

end
