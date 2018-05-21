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

ActiveRecord::Schema.define(version: 20120610091944) do

  create_table "companies", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "companies", ["name"], name: "index_companies_on_name", using: :btree

  create_table "priorities", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "position",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "priorities", ["name"], name: "index_priorities_on_name", using: :btree
  add_index "priorities", ["position"], name: "index_priorities_on_position", using: :btree

  create_table "project_roles", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.boolean  "can_close_tasks"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_roles", ["name"], name: "index_project_roles_on_name", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "customer_id", limit: 4
    t.integer  "supplier_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "projects", ["customer_id"], name: "index_projects_on_customer_id", using: :btree
  add_index "projects", ["supplier_id"], name: "index_projects_on_supplier_id", using: :btree

  create_table "statuses", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "position",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "statuses", ["name"], name: "index_statuses_on_name", using: :btree
  add_index "statuses", ["position"], name: "index_statuses_on_position", using: :btree

  create_table "tasks", force: :cascade do |t|
    t.string   "title",               limit: 255
    t.text     "description",         limit: 65535
    t.integer  "created_by_id",       limit: 4
    t.integer  "project_id",          limit: 4
    t.date     "due_date"
    t.integer  "priority_id",         limit: 4
    t.integer  "status_id",           limit: 4
    t.integer  "relevant_version_id", limit: 4
    t.integer  "expected_version_id", limit: 4
    t.float    "estimated_time",      limit: 24
    t.boolean  "archived"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tasks", ["created_by_id"], name: "index_tasks_on_created_by_id", using: :btree
  add_index "tasks", ["expected_version_id"], name: "index_tasks_on_expected_version_id", using: :btree
  add_index "tasks", ["priority_id"], name: "index_tasks_on_priority_id", using: :btree
  add_index "tasks", ["project_id"], name: "index_tasks_on_project_id", using: :btree
  add_index "tasks", ["relevant_version_id"], name: "index_tasks_on_relevant_version_id", using: :btree
  add_index "tasks", ["status_id"], name: "index_tasks_on_status_id", using: :btree
  add_index "tasks", ["title"], name: "index_tasks_on_title", using: :btree

  create_table "tasks_users", id: false, force: :cascade do |t|
    t.integer "task_id", limit: 4
    t.integer "user_id", limit: 4
  end

  add_index "tasks_users", ["task_id"], name: "index_tasks_users_on_task_id", using: :btree
  add_index "tasks_users", ["user_id"], name: "index_tasks_users_on_user_id", using: :btree

  create_table "user_project_participations", force: :cascade do |t|
    t.integer  "project_id",      limit: 4
    t.integer  "user_id",         limit: 4
    t.integer  "project_role_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_project_participations", ["project_id"], name: "index_user_project_participations_on_project_id", using: :btree
  add_index "user_project_participations", ["project_role_id"], name: "index_user_project_participations_on_project_role_id", using: :btree
  add_index "user_project_participations", ["user_id"], name: "index_user_project_participations_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["name"], name: "index_users_on_name", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "project_id", limit: 4
    t.string   "status",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "versions", ["name"], name: "index_versions_on_name", using: :btree
  add_index "versions", ["project_id"], name: "index_versions_on_project_id", using: :btree
  add_index "versions", ["status"], name: "index_versions_on_status", using: :btree

  create_table "wice_grid_serialized_queries", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "grid_name",  limit: 255
    t.text     "query",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wice_grid_serialized_queries", ["grid_name", "id"], name: "index_wice_grid_serialized_queries_on_grid_name_and_id", using: :btree
  add_index "wice_grid_serialized_queries", ["grid_name"], name: "index_wice_grid_serialized_queries_on_grid_name", using: :btree

end
