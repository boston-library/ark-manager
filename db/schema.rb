# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150727173528) do

  create_table "arks", force: true do |t|
    t.string   "namespace_ark"
    t.string   "url_base"
    t.string   "pid"
    t.string   "view_thumbnail"
    t.string   "view_object"
    t.string   "noid"
    t.string   "namespace_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "model_type"
    t.string   "local_original_identifier"
    t.string   "local_original_identifier_type"
    t.string   "parent_pid"
    t.boolean  "deleted"
    t.string   "secondary_parent_pids",          default: "--- []\n"
  end

end
