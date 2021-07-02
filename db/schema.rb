# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_06_29_152435) do

  create_table "addresses", force: :cascade do |t|
    t.string "add_01"
    t.string "add_02"
    t.string "add_03"
    t.string "add_04"
    t.string "country"
    t.integer "affiliation_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "affiliation_links", force: :cascade do |t|
    t.integer "affiliation_id"
    t.string "doi"
    t.integer "author_id"
    t.string "sequence"
    t.integer "address_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "affiliations", force: :cascade do |t|
    t.string "institution"
    t.string "department"
    t.string "faculty"
    t.string "work_group"
    t.string "country"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "sector"
  end

  create_table "article_authors", force: :cascade do |t|
    t.string "doi"
    t.integer "author_id"
    t.string "author_count"
    t.integer "author_order"
    t.string "status"
    t.string "author_seq"
    t.integer "article_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "orcid"
    t.string "last_name"
    t.string "given_name"
  end

  create_table "article_datasets", force: :cascade do |t|
    t.string "doi"
    t.integer "article_id"
    t.integer "dataset_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "article_themes", force: :cascade do |t|
    t.string "doi"
    t.integer "phase"
    t.string "collaboration"
    t.integer "theme_id"
    t.integer "article_id"
    t.integer "project_year"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "articles", force: :cascade do |t|
    t.integer "referenced_by_count"
    t.string "publisher"
    t.string "issue"
    t.string "license"
    t.integer "pub_print_year"
    t.integer "pub_print_month"
    t.integer "pub_print_day"
    t.string "doi"
    t.string "pub_type"
    t.string "page"
    t.string "title"
    t.string "volume"
    t.integer "pub_ol_year"
    t.integer "pub_ol_month"
    t.integer "pub_ol_day"
    t.string "container_title"
    t.string "link"
    t.integer "references_count"
    t.string "journal_issue"
    t.string "url"
    t.string "abstract"
    t.string "status"
    t.string "comment"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "pub_year"
  end

  create_table "author_affiliations", force: :cascade do |t|
    t.integer "article_author_id"
    t.string "name"
    t.string "short_name"
    t.string "add_01"
    t.string "add_02"
    t.string "add_03"
    t.string "add_04"
    t.string "add_05"
    t.string "country"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "affiliation_id"
  end

  create_table "authors", force: :cascade do |t|
    t.string "full_name"
    t.string "last_name"
    t.string "given_name"
    t.string "orcid"
    t.integer "articles"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "isap"
  end

  create_table "cr_affiliations", force: :cascade do |t|
    t.string "name"
    t.integer "article_author_id"
    t.integer "author_affiliation_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "datasets", force: :cascade do |t|
    t.string "dataset_complete"
    t.string "dataset_description"
    t.string "dataset_doi"
    t.string "dataset_enddate"
    t.string "dataset_location"
    t.string "dataset_name"
    t.string "dataset_startdate"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "ds_type"
    t.string "repository"
  end

  create_table "themes", force: :cascade do |t|
    t.string "short"
    t.string "name"
    t.string "lead"
    t.integer "phase"
    t.string "used"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "username"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end


  create_view "list_themes", sql_definition: <<-SQL
      SELECT themes.id, themes.phase, themes.name, themes.short, themes.lead, count() AS article_count
    FROM article_themes
    INNER JOIN themes on article_themes.theme_id = themes.id
    INNER JOIN articles on article_themes.article_id = articles.id
    WHERE articles.status == 'Added'
    GROUP BY themes.phase, themes.name
    ORDER BY themes.id
  SQL
  create_view "inst_ctry_stats", sql_definition: <<-SQL
    		SELECT country, count() as inst_count, SUM(res_count) as res_count, sum(pub_count)  AS pub_count 
			FROM (SELECT country, affi_name, COUNT(*) as res_count, sum(pub_count)  AS pub_count
				FROM (SELECT author_id, country, short_name AS affi_name, COUNT(*) AS pub_count
					FROM "authors" 
					INNER JOIN article_authors ON article_authors.author_id = authors.id 
					INNER JOIN author_affiliations ON author_affiliations.article_author_id = article_authors.id 
					GROUP BY author_id, short_name, country)
				GROUP BY country, affi_name)
			GROUP BY country
  SQL
end
