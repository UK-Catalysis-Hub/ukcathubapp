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

ActiveRecord::Schema[7.1].define(version: 2025_09_03_145548) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.text "name"
    t.text "record_type"
    t.bigint "record_id"
    t.bigint "blob_id"
    t.timestamptz "created_at"
    t.index ["blob_id"], name: "idx_26194_index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "idx_26194_index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.text "key"
    t.text "filename"
    t.text "content_type"
    t.text "metadata"
    t.text "service_name"
    t.bigint "byte_size"
    t.text "checksum"
    t.timestamptz "created_at"
    t.index ["key"], name: "idx_26187_index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id"
    t.text "variation_digest"
    t.index ["blob_id", "variation_digest"], name: "idx_26201_index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.text "add_01"
    t.text "add_02"
    t.text "add_03"
    t.text "add_04"
    t.text "city"
    t.text "province"
    t.text "country"
    t.bigint "affiliation_id"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
  end

  create_table "affiliations", force: :cascade do |t|
    t.text "institution"
    t.text "department"
    t.text "faculty"
    t.text "school"
    t.text "work_group"
    t.text "country"
    t.text "sector"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.bigint "organisation_id"
  end

  create_table "app_configs", force: :cascade do |t|
    t.text "title"
    t.text "browser_tab_name"
    t.bigint "organisation_id"
    t.bigint "contact_id"
    t.text "contact_email"
    t.text "award_list"
    t.text "synon_list"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
  end

  create_table "article_authors", force: :cascade do |t|
    t.text "doi"
    t.bigint "author_id"
    t.text "author_count"
    t.bigint "author_order"
    t.text "status"
    t.text "author_seq"
    t.bigint "article_id"
    t.text "orcid"
    t.text "last_name"
    t.text "given_name"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
  end

  create_table "article_datasets", force: :cascade do |t|
    t.text "doi"
    t.bigint "article_id"
    t.bigint "dataset_id"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
  end

  create_table "article_themes", force: :cascade do |t|
    t.text "doi"
    t.bigint "phase"
    t.text "collaboration"
    t.bigint "theme_id"
    t.bigint "article_id"
    t.bigint "project_year"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
  end

  create_table "articles", force: :cascade do |t|
    t.text "doi"
    t.text "title"
    t.bigint "pub_year"
    t.text "pub_type"
    t.text "publisher"
    t.text "container_title"
    t.text "volume"
    t.text "issue"
    t.text "page"
    t.bigint "pub_print_year"
    t.bigint "pub_print_month"
    t.bigint "pub_print_day"
    t.bigint "pub_ol_year"
    t.bigint "pub_ol_month"
    t.bigint "pub_ol_day"
    t.text "license"
    t.bigint "referenced_by_count"
    t.text "link"
    t.text "url"
    t.text "abstract"
    t.text "status"
    t.text "comment"
    t.bigint "references_count"
    t.text "journal_issue"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.text "pdf_file"
    t.text "graphic_abstract"
  end

  create_table "author_affiliations", force: :cascade do |t|
    t.bigint "article_author_id"
    t.text "name"
    t.text "short_name"
    t.text "add_01"
    t.text "add_02"
    t.text "add_03"
    t.text "add_04"
    t.text "add_05"
    t.text "city"
    t.text "province"
    t.text "country"
    t.bigint "affiliation_id"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
  end

  create_table "authors", force: :cascade do |t|
    t.text "last_name"
    t.text "given_name"
    t.text "orcid"
    t.boolean "isap"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
  end

  create_table "cr_affiliations", force: :cascade do |t|
    t.string "name"
    t.integer "article_author_id"
    t.integer "author_affiliation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cr_publications", force: :cascade do |t|
    t.text "authors"
    t.bigint "pub_year"
    t.text "title"
    t.text "doi"
    t.text "awards"
    t.text "xref_affi"
    t.text "themes"
    t.bigint "status"
    t.text "note"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.timestamptz "cut_date"
  end

  create_table "datasets", force: :cascade do |t|
    t.text "complete"
    t.text "description"
    t.text "doi"
    t.timestamptz "enddate"
    t.text "location"
    t.text "name"
    t.timestamptz "startdate"
    t.text "ds_type"
    t.text "repository"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
  end

  create_table "organisation_aliases", force: :cascade do |t|
    t.bigint "organisation_id"
    t.text "name"
    t.text "alias_type"
    t.timestamptz "valid_from"
    t.timestamptz "valid_to"
    t.text "laguage_code"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
  end

  create_table "organisations", force: :cascade do |t|
    t.text "name"
    t.text "short_name"
    t.text "identifier"
    t.text "logo"
    t.text "homepage"
    t.bigint "address_id"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.text "country"
    t.text "city"
    t.text "sector"
    t.text "region"
  end

  create_table "sections", force: :cascade do |t|
    t.text "obj_name"
    t.text "name"
    t.text "heading"
    t.text "description"
    t.boolean "visible"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
  end

  create_table "themes", force: :cascade do |t|
    t.text "short"
    t.text "name"
    t.text "lead"
    t.bigint "phase"
    t.text "used"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.text "theme_type"
  end

  create_table "users", force: :cascade do |t|
    t.text "email", default: ""
    t.text "encrypted_password", default: ""
    t.text "reset_password_token"
    t.timestamptz "reset_password_sent_at"
    t.timestamptz "remember_created_at"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.text "confirmation_token"
    t.timestamptz "confirmed_at"
    t.timestamptz "confirmation_sent_at"
    t.text "unconfirmed_email"
    t.text "username"
    t.index ["email"], name: "idx_26157_index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "idx_26157_index_users_on_reset_password_token", unique: true
  end

  create_table "xref_client_mappings", force: :cascade do |t|
    t.text "obj_name"
    t.text "origin"
    t.text "target"
    t.text "target_type"
    t.text "default"
    t.text "json_paths"
    t.text "evaluate"
    t.text "other"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id", name: "active_storage_attachments_blob_id_fkey"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id", name: "active_storage_variant_records_blob_id_fkey"

  create_view "inst_ctry_stats", sql_definition: <<-SQL
      SELECT v_ctry_inst.country,
      count(*) AS inst_count,
      sum(v_ctry_inst.res_count) AS res_count,
      sum(v_ctry_inst.pub_count) AS pub_count
     FROM ( SELECT v_author_inst.country,
              v_author_inst.affi_name,
              count(*) AS res_count,
              sum(v_author_inst.pub_count) AS pub_count
             FROM ( SELECT article_authors.author_id,
                      author_affiliations.country,
                      author_affiliations.short_name AS affi_name,
                      count(*) AS pub_count
                     FROM ((authors
                       JOIN article_authors ON ((article_authors.author_id = authors.id)))
                       JOIN author_affiliations ON ((author_affiliations.article_author_id = article_authors.id)))
                    GROUP BY article_authors.author_id, author_affiliations.short_name, author_affiliations.country) v_author_inst
            GROUP BY v_author_inst.country, v_author_inst.affi_name) v_ctry_inst
    GROUP BY v_ctry_inst.country;
  SQL
  create_view "list_themes", sql_definition: <<-SQL
      SELECT themes.id,
      themes.phase,
      themes.name,
      themes.short,
      themes.lead,
      count(*) AS article_count
     FROM ((article_themes
       JOIN themes ON ((article_themes.theme_id = themes.id)))
       JOIN articles ON ((article_themes.article_id = articles.id)))
    WHERE (articles.status = 'Added'::text)
    GROUP BY themes.id, themes.phase, themes.name
    ORDER BY themes.id;
  SQL
end
