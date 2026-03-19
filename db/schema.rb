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

ActiveRecord::Schema[7.2].define(version: 2026_03_19_012549) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "announcement_classrooms", force: :cascade do |t|
    t.bigint "announcement_id", null: false
    t.bigint "classroom_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["announcement_id"], name: "index_announcement_classrooms_on_announcement_id"
    t.index ["classroom_id"], name: "index_announcement_classrooms_on_classroom_id"
  end

  create_table "announcement_students", force: :cascade do |t|
    t.bigint "announcement_id", null: false
    t.bigint "student_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["announcement_id"], name: "index_announcement_students_on_announcement_id"
    t.index ["student_id"], name: "index_announcement_students_on_student_id"
  end

  create_table "announcements", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.string "title"
    t.text "content"
    t.string "attachment_url"
    t.string "scope"
    t.string "status"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_announcements_on_school_id"
  end

  create_table "classrooms", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.string "name"
    t.string "grade"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_classrooms_on_school_id"
  end

  create_table "delivery_logs", force: :cascade do |t|
    t.bigint "announcement_id", null: false
    t.bigint "guardian_id", null: false
    t.boolean "read"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["announcement_id"], name: "index_delivery_logs_on_announcement_id"
    t.index ["guardian_id"], name: "index_delivery_logs_on_guardian_id"
  end

  create_table "guardians", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "schools", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "student_classrooms", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "classroom_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classroom_id"], name: "index_student_classrooms_on_classroom_id"
    t.index ["student_id"], name: "index_student_classrooms_on_student_id"
  end

  create_table "student_guardians", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "guardian_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guardian_id"], name: "index_student_guardians_on_guardian_id"
    t.index ["student_id"], name: "index_student_guardians_on_student_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "announcement_classrooms", "announcements"
  add_foreign_key "announcement_classrooms", "classrooms"
  add_foreign_key "announcement_students", "announcements"
  add_foreign_key "announcement_students", "students"
  add_foreign_key "announcements", "schools"
  add_foreign_key "classrooms", "schools"
  add_foreign_key "delivery_logs", "announcements"
  add_foreign_key "delivery_logs", "guardians"
  add_foreign_key "student_classrooms", "classrooms"
  add_foreign_key "student_classrooms", "students"
  add_foreign_key "student_guardians", "guardians"
  add_foreign_key "student_guardians", "students"
end
