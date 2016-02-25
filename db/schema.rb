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

ActiveRecord::Schema.define(version: 20160224062213) do

  create_table "admins", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "job_number",         limit: 50
    t.string   "password_digest"
    t.string   "name",               limit: 50
    t.string   "permissions",        limit: 50
    t.string   "position",           limit: 50
    t.integer  "age"
    t.integer  "gender"
    t.string   "email",              limit: 50
    t.string   "phone",              limit: 50
    t.string   "address"
    t.integer  "sign_in_count"
    t.datetime "current_sign_in_at"
    t.string   "current_sign_in_ip", limit: 50
    t.datetime "last_sign_in_at"
    t.string   "last_sign_in_ip",    limit: 50
    t.integer  "failed_attempts"
    t.datetime "locked_at"
    t.string   "access_token"
    t.datetime "last_activity_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["access_token"], name: "index_admins_on_access_token", unique: true, using: :btree
    t.index ["job_number"], name: "index_admins_on_job_number", unique: true, using: :btree
    t.index ["name"], name: "index_admins_on_name", using: :btree
  end

  create_table "competitions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",                           null: false
    t.text     "description",      limit: 65535
    t.string   "cover"
    t.string   "guide_units"
    t.string   "organizer_units"
    t.string   "help_units"
    t.string   "support_units"
    t.string   "undertake_units"
    t.text     "video",            limit: 65535
    t.text     "file",             limit: 65535
    t.integer  "status"
    t.integer  "team_min_num"
    t.integer  "team_max_num"
    t.datetime "apply_start_time"
    t.datetime "apply_end_time"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "keyword"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["end_time"], name: "index_competitions_on_end_time", using: :btree
    t.index ["name"], name: "index_competitions_on_name", unique: true, using: :btree
    t.index ["start_time"], name: "index_competitions_on_start_time", using: :btree
    t.index ["status"], name: "index_competitions_on_status", using: :btree
  end

  create_table "email_codes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "email",           limit: 20
    t.string   "code",            limit: 20
    t.string   "message_type",    limit: 20
    t.integer  "failed_attempts"
    t.string   "ip",              limit: 50
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["email"], name: "index_email_codes_on_email", using: :btree
    t.index ["ip"], name: "index_email_codes_on_ip", using: :btree
    t.index ["message_type"], name: "index_email_codes_on_message_type", using: :btree
  end

  create_table "mobile_codes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "mobile",          limit: 20
    t.string   "code",            limit: 20
    t.string   "message_type",    limit: 20
    t.integer  "failed_attempts"
    t.string   "ip",              limit: 50
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["ip"], name: "index_mobile_codes_on_ip", using: :btree
    t.index ["message_type"], name: "index_mobile_codes_on_message_type", using: :btree
    t.index ["mobile"], name: "index_mobile_codes_on_mobile", using: :btree
  end

  create_table "user_profiles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.string   "username"
    t.integer  "gender"
    t.integer  "age"
    t.string   "school"
    t.string   "student_code"
    t.string   "identity_card"
    t.string   "nationality"
    t.string   "grade"
    t.string   "bj"
    t.string   "autograph"
    t.string   "address"
    t.date     "birthday"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["gender"], name: "index_user_profiles_on_gender", using: :btree
    t.index ["identity_card"], name: "index_user_profiles_on_identity_card", using: :btree
    t.index ["school"], name: "index_user_profiles_on_school", using: :btree
    t.index ["student_code"], name: "index_user_profiles_on_student_code", using: :btree
    t.index ["user_id"], name: "index_user_profiles_on_user_id", unique: true, using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "email",                  default: "",  null: false
    t.string   "encrypted_password",     default: "",  null: false
    t.string   "mobile"
    t.string   "nickname"
    t.string   "avatar"
    t.string   "validate_status",        default: "0"
    t.string   "private_token"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,   null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,   null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.index ["email"], name: "index_users_on_email", using: :btree
    t.index ["mobile"], name: "index_users_on_mobile", using: :btree
    t.index ["nickname"], name: "index_users_on_nickname", unique: true, using: :btree
    t.index ["private_token"], name: "index_users_on_private_token", unique: true, using: :btree
  end

end
