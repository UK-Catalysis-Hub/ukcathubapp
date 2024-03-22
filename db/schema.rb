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

ActiveRecord::Schema[7.1].define(version: 2024_03_22_191525) do
  create_table "addresses", force: :cascade do |t|
    t.string "add_01"
    t.string "add_02"
    t.string "add_03"
    t.string "add_04"
    t.string "city"
    t.string "province"
    t.string "country"
    t.integer "affiliation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "affiliations", force: :cascade do |t|
    t.string "institution"
    t.string "department"
    t.string "faculty"
    t.string "school"
    t.string "work_group"
    t.string "country"
    t.string "sector"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "article_authors", force: :cascade do |t|
    t.string "doi"
    t.integer "author_id"
    t.string "author_count"
    t.integer "author_order"
    t.string "status"
    t.string "author_seq"
    t.integer "article_id"
    t.string "orcid"
    t.string "last_name"
    t.string "given_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "article_datasets", force: :cascade do |t|
    t.string "doi"
    t.integer "article_id"
    t.integer "dataset_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "article_themes", force: :cascade do |t|
    t.string "doi"
    t.integer "phase"
    t.string "collaboration"
    t.integer "theme_id"
    t.integer "article_id"
    t.integer "project_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

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
    t.string "pdf_file"
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
    t.string "city"
    t.string "province"
    t.string "country"
    t.integer "affiliation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "authors", force: :cascade do |t|
    t.string "last_name"
    t.string "given_name"
    t.string "orcid"
    t.boolean "isap"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cr_affiliations", force: :cascade do |t|
    t.string "name"
    t.string "article_author_id"
    t.string "author_affiliation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "datasets", force: :cascade do |t|
    t.string "complete"
    t.string "description"
    t.string "doi"
    t.datetime "enddate"
    t.string "location"
    t.string "name"
    t.datetime "startdate"
    t.string "ds_type"
    t.string "repository"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "themes", force: :cascade do |t|
    t.string "short"
    t.string "name"
    t.string "lead"
    t.integer "phase"
    t.string "used"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end


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
  create_view "list_themes", sql_definition: <<-SQL
      SELECT themes.id, themes.phase, themes.name, themes.short, themes.lead, count() AS article_count
    FROM article_themes
    INNER JOIN themes on article_themes.theme_id = themes.id
    INNER JOIN articles on article_themes.article_id = articles.id
    WHERE articles.status == 'Added'
    GROUP BY themes.phase, themes.name
    ORDER BY themes.id
  SQL
end
