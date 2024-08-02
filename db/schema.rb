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

ActiveRecord::Schema[7.1].define(version: 2024_08_02_135441) do
  create_table "articles", force: :cascade do |t|
    t.string "doi"
    t.string "title"
    t.integer "pub_year"
    t.string "pub_type"
    t.string "publisher"
    t.string "container_title"
    t.string "volume"
    t.string "issue"
    t.string "page"
    t.integer "pub_print_year"
    t.integer "pub_print_month"
    t.integer "pub_print_day"
    t.integer "pub_ol_year"
    t.integer "pub_ol_month"
    t.integer "pub_ol_day"
    t.string "license"
    t.integer "referenced_by_count"
    t.string "link"
    t.string "url"
    t.text "abstract"
    t.string "status"
    t.string "comment"
    t.integer "references_count"
    t.string "journal_issue"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
