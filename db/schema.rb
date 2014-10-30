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

ActiveRecord::Schema.define(version: 20141029095545) do

  create_table "admins", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "grammar_groups", force: true do |t|
    t.string   "sequence_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "grammar_type_id"
  end

  add_index "grammar_groups", ["grammar_type_id"], name: "index_grammar_groups_on_grammar_type_id", using: :btree

  create_table "grammar_questions", force: true do |t|
    t.string   "sequence_number"
    t.text     "content"
    t.integer  "grammar_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "grammar_questions", ["grammar_group_id"], name: "index_grammar_questions_on_grammar_group_id", using: :btree

  create_table "grammar_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "upload_vocabularies", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vocabulary_groups", force: true do |t|
    t.string   "sequence_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vocabulary_questions", force: true do |t|
    t.string   "sequence_number"
    t.text     "content"
    t.integer  "vocabulary_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "word"
  end

  add_index "vocabulary_questions", ["vocabulary_group_id"], name: "index_vocabulary_questions_on_vocabulary_group_id", using: :btree

end
