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

ActiveRecord::Schema.define(version: 20210505131230) do

  create_table "atom_feed_reads", force: :cascade do |t|
    t.text     "title",               limit: 65535,                 null: false
    t.datetime "avalon_last_updated",                               null: false
    t.string   "json_url",            limit: 255,                   null: false
    t.string   "avalon_item_url",     limit: 255,                   null: false
    t.string   "avalon_id",           limit: 255,                   null: false
    t.boolean  "successfully_read",                 default: false
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.boolean  "json_failed",                       default: false
    t.text     "json_error_message",  limit: 65535
    t.text     "entry_xml",           limit: 65535
  end

  add_index "atom_feed_reads", ["avalon_id"], name: "index_atom_feed_reads_on_avalon_id", unique: true, using: :btree

  create_table "avalon_item_notes", force: :cascade do |t|
    t.integer  "avalon_item_id", limit: 8,     null: false
    t.text     "text",           limit: 65535
    t.string   "creator",        limit: 255,   null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "avalon_item_people", force: :cascade do |t|
    t.integer  "person_id",      limit: 8
    t.integer  "avalon_item_id", limit: 8
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "avalon_item_works", force: :cascade do |t|
    t.integer  "avalon_item_id", limit: 8
    t.integer  "work_id",        limit: 8
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "avalon_items", force: :cascade do |t|
    t.text     "title",                           limit: 65535,                    null: false
    t.string   "avalon_id",                       limit: 255,                      null: false
    t.text     "json",                            limit: 16777215,                 null: false
    t.string   "pod_unit",                        limit: 255,                      null: false
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.boolean  "needs_review"
    t.boolean  "reviewed"
    t.integer  "current_access_determination_id", limit: 8
    t.integer  "review_state",                    limit: 4,        default: 0,     null: false
    t.boolean  "modified_in_mco",                                  default: false
    t.text     "collection",                      limit: 65535
  end

  add_index "avalon_items", ["avalon_id"], name: "index_avalon_items_on_avalon_id", unique: true, using: :btree

  create_table "contracts", force: :cascade do |t|
    t.string  "date_edtf_text", limit: 255
    t.date    "end_date"
    t.string  "contract_type",  limit: 255
    t.text    "notes",          limit: 65535
    t.boolean "perpetual"
    t.integer "avalon_item_id", limit: 4
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "iu_affiliations", force: :cascade do |t|
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "nationalities", force: :cascade do |t|
    t.string   "nationality", limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "past_access_decisions", force: :cascade do |t|
    t.integer  "avalon_item_id",      limit: 8
    t.string   "decision",            limit: 255
    t.string   "changed_by",          limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.boolean  "copyright_librarian",             default: false
  end

  create_table "people", force: :cascade do |t|
    t.string   "date_of_birth_edtf",   limit: 255
    t.string   "date_of_death_edtf",   limit: 255
    t.string   "place_of_birth",       limit: 255
    t.string   "authority_source",     limit: 255
    t.string   "aka",                  limit: 255
    t.text     "notes",                limit: 65535
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.text     "authority_source_url", limit: 65535
    t.string   "first_name",           limit: 255
    t.string   "last_name",            limit: 255
    t.date     "date_of_birth"
    t.date     "date_of_death"
    t.string   "middle_name",          limit: 255
    t.boolean  "entity"
    t.text     "company_name",         limit: 65535
    t.text     "entity_nationality",   limit: 65535
  end

  create_table "performance_contributor_people", force: :cascade do |t|
    t.integer  "performance_id", limit: 8
    t.integer  "person_id",      limit: 8
    t.integer  "role_id",        limit: 8
    t.integer  "contract_id",    limit: 8
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "performance_notes", force: :cascade do |t|
    t.integer  "performance_id", limit: 8,     null: false
    t.text     "text",           limit: 65535
    t.string   "creator",        limit: 255,   null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "performances", force: :cascade do |t|
    t.integer  "work_id",                 limit: 8
    t.string   "location",                limit: 255
    t.date     "performance_date"
    t.string   "notes",                   limit: 255
    t.string   "access_determination",    limit: 255
    t.integer  "copyright_end_date",      limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "performance_date_string", limit: 255
    t.string   "title",                   limit: 255
    t.string   "in_copyright",            limit: 255
  end

  create_table "person_iu_affiliations", force: :cascade do |t|
    t.integer  "person_id",         limit: 8
    t.integer  "iu_affiliation_id", limit: 4
    t.integer  "begin_date",        limit: 4
    t.integer  "end_date",          limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "person_nationalities", force: :cascade do |t|
    t.integer  "person_id",      limit: 8
    t.integer  "nationality_id", limit: 8
    t.date     "begin_date"
    t.date     "end_date"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "pod_objects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pod_physical_objects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pod_pulls", force: :cascade do |t|
    t.datetime "pull_timestamp", null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "pod_workflow_statuses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "policies", force: :cascade do |t|
    t.integer  "begin_date", limit: 4
    t.date     "end_date"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "recording_contributor_people", force: :cascade do |t|
    t.integer  "contract_id",               limit: 8
    t.integer  "recording_id",              limit: 8
    t.integer  "role_id",                   limit: 8
    t.integer  "person_id",                 limit: 8
    t.integer  "policy_id",                 limit: 8
    t.boolean  "relationship_to_depositor"
    t.text     "notes",                     limit: 65535
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.boolean  "recording_depositor"
    t.boolean  "recording_producer"
  end

  create_table "recording_notes", force: :cascade do |t|
    t.integer  "recording_id", limit: 8,     null: false
    t.text     "text",         limit: 65535
    t.string   "creator",      limit: 255,   null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "recording_performances", force: :cascade do |t|
    t.integer  "recording_id",   limit: 8
    t.integer  "performance_id", limit: 8
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "recording_take_down_notices", force: :cascade do |t|
    t.integer  "recording_id",        limit: 8
    t.integer  "take_down_notice_id", limit: 8
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "recordings", force: :cascade do |t|
    t.text     "title",                                   limit: 65535
    t.text     "description",                             limit: 65535
    t.date     "creation_date"
    t.boolean  "published"
    t.date     "date_of_first_publication"
    t.string   "country_of_first_publication",            limit: 255
    t.boolean  "receipt_of_will_before_90_days_of_death"
    t.boolean  "iu_produced_recording"
    t.integer  "creation_end_date",                       limit: 4
    t.string   "format",                                  limit: 255
    t.integer  "mdpi_barcode",                            limit: 8
    t.string   "authority_source",                        limit: 255
    t.string   "access_determination",                    limit: 255
    t.string   "in_copyright",                            limit: 255,   default: ""
    t.date     "copyright_end_date"
    t.text     "decision_comment",                        limit: 65535
    t.datetime "created_at",                                                            null: false
    t.datetime "updated_at",                                                            null: false
    t.text     "catalog_key",                             limit: 65535
    t.boolean  "commercial"
    t.string   "fedora_item_id",                          limit: 255
    t.boolean  "needs_review",                                          default: false
    t.string   "last_updated_by",                         limit: 255
    t.string   "unit",                                    limit: 255,                   null: false
    t.integer  "atom_feed_read_id",                       limit: 8
    t.integer  "avalon_item_id",                          limit: 8
    t.text     "authority_source_url",                    limit: 65535
    t.string   "copyright_end_date_text",                 limit: 255
    t.string   "date_of_first_publication_text",          limit: 255
    t.string   "creation_date_text",                      limit: 255
  end

  add_index "recordings", ["avalon_item_id"], name: "index_recordings_on_avalon_item_id", using: :btree

  create_table "review_comments", force: :cascade do |t|
    t.integer  "avalon_item_id",      limit: 4
    t.string   "creator",             limit: 255,   null: false
    t.boolean  "copyright_librarian"
    t.text     "comment",             limit: 65535, null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "take_down_notices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "track_contributor_people", force: :cascade do |t|
    t.integer  "track_id",          limit: 8
    t.integer  "person_id",         limit: 8
    t.string   "role",              limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.boolean  "contributor"
    t.boolean  "principle_creator"
    t.boolean  "interviewer"
    t.boolean  "performer"
    t.boolean  "conductor"
    t.boolean  "interviewee"
  end

  create_table "track_works", force: :cascade do |t|
    t.integer  "track_id",   limit: 8
    t.integer  "work_id",    limit: 8
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "tracks", force: :cascade do |t|
    t.integer  "performance_id",          limit: 8,   null: false
    t.string   "track_name",              limit: 255, null: false
    t.integer  "recording_start_time",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "recording_end_time",      limit: 4
    t.date     "copyright_end_date"
    t.string   "access_determination",    limit: 255
    t.string   "in_copyright",            limit: 255
    t.string   "copyright_end_date_text", limit: 255
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "username",     limit: 255
    t.boolean  "ignore_ads",               default: false
    t.boolean  "b_aaai"
    t.boolean  "b_aaamc"
    t.boolean  "b_afrist"
    t.boolean  "b_alf"
    t.boolean  "b_anth"
    t.boolean  "b_archives"
    t.boolean  "b_astr"
    t.boolean  "b_athbaskm"
    t.boolean  "b_athbaskw"
    t.boolean  "b_athfhockey"
    t.boolean  "b_athftbl"
    t.boolean  "b_athrowing"
    t.boolean  "b_athsoccm"
    t.boolean  "b_athsoftb"
    t.boolean  "b_athtennm"
    t.boolean  "b_athvideo"
    t.boolean  "b_athvollw"
    t.boolean  "b_atm"
    t.boolean  "b_bcc"
    t.boolean  "b_bfca"
    t.boolean  "b_busspea"
    t.boolean  "b_cac"
    t.boolean  "b_cdel"
    t.boolean  "b_cedir"
    t.boolean  "b_celcar"
    t.boolean  "b_celtie"
    t.boolean  "b_ceus"
    t.boolean  "b_chem"
    t.boolean  "b_cisab"
    t.boolean  "b_clacs"
    t.boolean  "b_cmcl"
    t.boolean  "b_creole"
    t.boolean  "b_cshm"
    t.boolean  "b_cyclotrn"
    t.boolean  "b_easc"
    t.boolean  "b_educ"
    t.boolean  "b_eppley"
    t.boolean  "b_facility"
    t.boolean  "b_finearts"
    t.boolean  "b_folkethno"
    t.boolean  "b_franklin"
    t.boolean  "b_gbl"
    t.boolean  "b_geology"
    t.boolean  "b_glbtsssl"
    t.boolean  "b_gleim"
    t.boolean  "b_global"
    t.boolean  "b_hper"
    t.boolean  "b_ias"
    t.boolean  "b_iaunrc"
    t.boolean  "b_iprc"
    t.boolean  "b_iuam"
    t.boolean  "b_iulmia"
    t.boolean  "b_jourschl"
    t.boolean  "b_kinsey"
    t.boolean  "b_lacasa"
    t.boolean  "b_law"
    t.boolean  "b_liberia"
    t.boolean  "b_lifesci"
    t.boolean  "b_lilly"
    t.boolean  "b_ling"
    t.boolean  "b_mathers"
    t.boolean  "b_mdp"
    t.boolean  "b_musbands"
    t.boolean  "b_music"
    t.boolean  "b_musopera"
    t.boolean  "b_musrec"
    t.boolean  "b_oid"
    t.boolean  "b_optmschl"
    t.boolean  "b_optomtry"
    t.boolean  "b_polish"
    t.boolean  "b_psych"
    t.boolean  "b_recsports"
    t.boolean  "b_reei"
    t.boolean  "b_rtvs"
    t.boolean  "b_sage"
    t.boolean  "b_savail"
    t.boolean  "b_swain"
    t.boolean  "b_tai"
    t.boolean  "b_thtr"
    t.boolean  "b_undrwatr"
    t.boolean  "b_univcomm"
    t.boolean  "b_wells"
    t.boolean  "b_west"
    t.boolean  "ea_archives"
    t.boolean  "ea_athl"
    t.boolean  "i_archives"
    t.boolean  "i_dent"
    t.boolean  "i_libr_sca"
    t.boolean  "i_raybrad"
    t.boolean  "ko_archives"
    t.boolean  "nw_archives"
    t.boolean  "sb_archives"
    t.boolean  "sb_phys"
    t.boolean  "sb_ulib"
    t.boolean  "se_archives"
  end

  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "work_contributor_people", force: :cascade do |t|
    t.integer  "work_id",           limit: 8
    t.integer  "person_id",         limit: 8
    t.integer  "role_id",           limit: 8
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "principle_creator"
    t.boolean  "contributor"
  end

  create_table "works", force: :cascade do |t|
    t.string   "title",                          limit: 255
    t.string   "traditional",                    limit: 255
    t.string   "contemporary_work_in_copyright", limit: 255
    t.string   "restored_copyright",             limit: 255
    t.text     "alternative_titles",             limit: 65535
    t.string   "publication_date_edtf",          limit: 255
    t.string   "authority_source",               limit: 255
    t.text     "notes",                          limit: 65535
    t.string   "access_determination",           limit: 255
    t.string   "copyright_end_date_edtf",        limit: 255
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.text     "authority_source_url",           limit: 65535
    t.date     "publication_date"
    t.date     "copyright_end_date"
    t.string   "copyright_renewed",              limit: 255
  end

end
