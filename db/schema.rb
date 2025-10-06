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

ActiveRecord::Schema[8.0].define(version: 2025_10_06_053721) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "applications", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "user_id", null: false
    t.text "cover_letter"
    t.datetime "applied_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
    t.index ["applied_at"], name: "index_applications_on_applied_at"
    t.index ["job_id", "user_id"], name: "index_applications_on_job_id_and_user_id", unique: true
    t.index ["job_id"], name: "index_applications_on_job_id"
    t.index ["status"], name: "index_applications_on_status"
    t.index ["user_id"], name: "index_applications_on_user_id"
  end

  create_table "bookmarks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "job_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_bookmarks_on_job_id"
    t.index ["user_id", "job_id"], name: "index_bookmarks_on_user_id_and_job_id", unique: true
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.text "description"
    t.string "location"
    t.string "website"
    t.string "industry"
    t.string "size"
    t.string "logo"
    t.datetime "approved_at"
    t.bigint "approved_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
    t.index ["approved_by_id"], name: "index_companies_on_approved_by_id"
    t.index ["industry"], name: "index_companies_on_industry"
    t.index ["slug"], name: "index_companies_on_slug", unique: true
    t.index ["status"], name: "index_companies_on_status"
  end

  create_table "job_recommendations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.json "payload", null: false
    t.string "algorithm_version", null: false
    t.datetime "generated_at", null: false
    t.datetime "scheduled_for"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["scheduled_for"], name: "index_job_recommendations_on_scheduled_for"
    t.index ["user_id"], name: "index_job_recommendations_on_user_id"
  end

  create_table "job_skills", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "skill_id", null: false
    t.boolean "required", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id", "skill_id"], name: "index_job_skills_on_job_id_and_skill_id", unique: true
    t.index ["job_id"], name: "index_job_skills_on_job_id"
    t.index ["skill_id"], name: "index_job_skills_on_skill_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.string "title", null: false
    t.bigint "company_id", null: false
    t.bigint "posted_by_user_id", null: false
    t.text "description", null: false
    t.decimal "salary_min", precision: 10, scale: 2
    t.decimal "salary_max", precision: 10, scale: 2
    t.string "currency", default: "USD"
    t.boolean "visibility", default: true
    t.datetime "published_at"
    t.datetime "expires_at"
    t.datetime "application_deadline"
    t.integer "views_count", default: 0
    t.integer "applications_count", default: 0
    t.string "location"
    t.boolean "is_remote", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "employment_type"
    t.integer "status", default: 0, null: false
    t.index ["company_id"], name: "index_jobs_on_company_id"
    t.index ["employment_type"], name: "index_jobs_on_employment_type"
    t.index ["expires_at"], name: "index_jobs_on_expires_at"
    t.index ["posted_by_user_id"], name: "index_jobs_on_posted_by_user_id"
    t.index ["published_at"], name: "index_jobs_on_published_at"
    t.index ["status"], name: "index_jobs_on_status"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "content"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "kind"
    t.index ["kind"], name: "index_notifications_on_kind"
    t.index ["read_at"], name: "index_notifications_on_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "recruiter_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "company_id", null: false
    t.string "title"
    t.boolean "is_primary", default: false
    t.json "contact_info", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role"
    t.integer "status", default: 0, null: false
    t.index ["company_id"], name: "index_recruiter_memberships_on_company_id"
    t.index ["role"], name: "index_recruiter_memberships_on_role"
    t.index ["status"], name: "index_recruiter_memberships_on_status"
    t.index ["user_id", "company_id"], name: "index_recruiter_memberships_on_user_id_and_company_id", unique: true
    t.index ["user_id"], name: "index_recruiter_memberships_on_user_id"
  end

  create_table "skills", force: :cascade do |t|
    t.string "name", null: false
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_skills_on_category"
    t.index ["name"], name: "index_skills_on_name", unique: true
  end

  create_table "user_skills", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "skill_id", null: false
    t.integer "experience_years", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["skill_id"], name: "index_user_skills_on_skill_id"
    t.index ["user_id", "skill_id"], name: "index_user_skills_on_user_id_and_skill_id", unique: true
    t.index ["user_id"], name: "index_user_skills_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "username", null: false
    t.string "password_encrypted"
    t.string "bio"
    t.string "location"
    t.boolean "email_verified", default: false
    t.json "notification_preferences", default: {}
    t.boolean "weekly_recommendations_enabled", default: true
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role"
    t.string "authentication_token"
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "applications", "jobs"
  add_foreign_key "applications", "users"
  add_foreign_key "bookmarks", "jobs"
  add_foreign_key "bookmarks", "users"
  add_foreign_key "companies", "users", column: "approved_by_id"
  add_foreign_key "job_recommendations", "users"
  add_foreign_key "job_skills", "jobs"
  add_foreign_key "job_skills", "skills"
  add_foreign_key "jobs", "companies"
  add_foreign_key "jobs", "users", column: "posted_by_user_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "recruiter_memberships", "companies"
  add_foreign_key "recruiter_memberships", "users"
  add_foreign_key "user_skills", "skills"
  add_foreign_key "user_skills", "users"
end
