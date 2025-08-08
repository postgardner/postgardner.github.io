# db/schema.rb
# frozen_string_literal: true

ActiveRecord::Schema[7.1].define(version: 2025_08_08_000001) do
  enable_extension "plpgsql"

  # --- Core directory -------------------------------------------------------

  create_table "users", force: :cascade do |t|
    t.string   "email",              null: false
    t.string   "full_name",          null: false
    t.string   "role",               null: false, default: "user"
    t.boolean  "active",             null: false, default: true
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end
  add_index "users", ["email"], unique: true

  # Party = base entity for Organization & Person
  create_table "parties", id: :bigserial, force: :cascade do |t|
    t.string   "party_type",         null: false # "organization" | "person" 【11:19-L19】
    t.string   "status",             null: false, default: "active" # new/active/inactive/archived 【10:23-L23】
    t.string   "source_origin",      null: false, default: "manual" # import/website/manual (immutable in app layer) 【3:15-L15】
    t.string   "source_ref"                              # external id if any 【3:15-L15】
    t.bigint   "owner_id"                                # Account Owner 【3:17-L17】
    t.jsonb    "verification",     null: false, default: {} # per-field verification flags
    t.jsonb    "custom_fields",    null: false, default: {}
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end
  add_foreign_key "parties", "users", column: "owner_id"

  # Organization-specific
  create_table "organizations", id: :bigserial, force: :cascade do |t|
    t.bigint "party_id",            null: false
    t.string "industry"                               # галузь 【0:13-L13】
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end
  add_index "organizations", ["party_id"], unique: true
  add_foreign_key "organizations", "parties", column: "party_id"

  # Multilingual names & aliases for organizations
  create_table "party_names", force: :cascade do |t|
    t.bigint "party_id",            null: false
    t.string "kind",                null: false, default: "official" # official | alias 【0:15-L15】
    t.string "name",                null: false
    t.string "language_code"                          # e.g., "uk", "en"
    t.boolean "primary",            null: false, default: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end
  add_index "party_names", ["party_id"]
  add_index "party_names", ["party_id", "name", "language_code"], unique: true
  add_foreign_key "party_names", "parties", column: "party_id"

  # Person-specific
  create_table "people", id: :bigserial, force: :cascade do |t|
    t.bigint  "party_id",           null: false
    t.date    "birth_date"                           # дата народження 【4:19-L19】
    t.string  "gender"                               # стать 【4:21-L21】
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end
  add_index "people", ["party_id"], unique: true
  add_foreign_key "people", "parties", column: "party_id"

  # Tags (free-form, grouped & color-coded)
  create_table "tags", force: :cascade do |t|
    t.string  "name",               null: false      # довільні теги 【3:23-L23】
    t.string  "group"
    t.string  "color"
    t.boolean "active",             null: false, default: true
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end
  add_index "tags", ["name"], unique: true

  create_table "taggings", force: :cascade do |t|
    t.bigint "tag_id",              null: false
    t.bigint "party_id",            null: false
    t.datetime "created_at",        null: false
  end
  add_index "taggings", ["tag_id", "party_id"], unique: true
  add_foreign_key "taggings", "tags"
  add_foreign_key "taggings", "parties"

  # Official identifiers (EDRPOU, RNOCPP/INN)
  create_table "identities", force: :cascade do |t|
    t.bigint "party_id",            null: false
    t.string "id_type",             null: false      # edrpou | rnokpp | inn ... 【1:31-L31】
    t.string "value",               null: false
    t.string "country"
    t.string "verification_status", null: false, default: "unverified"
    t.date   "valid_from"
    t.date   "valid_to"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end
  add_index "identities", ["id_type", "value"], unique: true # exact-match dedupe key 【10:21-L21】
  add_index "identities", ["party_id"]
  add_foreign_key "identities", "parties", column: "party_id"
  # Optional: format checks (Rails migration should add DB check constraints) 【1:33-L33】

  # Contact mechanisms (emails, phones, etc.) with purposes and primary per purpose
  create_table "contact_channels", force: :cascade do |t|
    t.bigint "party_id",            null: false
    t.string "kind",                null: false      # email | phone | other 【1:9-L9】
    t.string "value",               null: false
    t.string "normalized_value"                       # E.164/email normalized for dedupe
    t.string "purpose",             null: false      # work | personal | billing ... 【1:11-L11】
    t.boolean "is_primary",         null: false, default: false # one per purpose 【1:13-L13】
    t.string  "verification_status", null: false, default: "unverified"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end
  add_index "contact_channels", ["party_id"]
  add_index "contact_channels", ["normalized_value", "kind"], unique: true, where: "normalized_value IS NOT NULL" # exact-match dedupe key
  add_index "contact_channels", ["party_id", "purpose"], unique: true, where: "is_primary" # one primary per purpose 【1:13-L13】
  add_foreign_key "contact_channels", "parties", column: "party_id"

  # Addresses (incl. pickup-point for delivery)
  create_table "addresses", force: :cascade do |t|
    t.bigint "party_id",            null: false
    t.string "kind",                null: false      # legal | actual | shipping | pickup_point 【1:17-L17】【1:19-L21】
    t.string "country"
    t.string "region"
    t.string "city"
    t.string "postal_code"
    t.string "street1"
    t.string "street2"
    t.string "building"
    t.string "apartment"
    t.decimal "lat", precision: 10, scale: 6
    t.decimal "lng", precision: 10, scale: 6
    # pickup-point specifics:
    t.string "delivery_service"                      # nova_poshta | ukrposhta ... 【5:1-L1】
    t.string "pickup_point_ref"                      # branch/postomat id 【1:21-L21】
    t.boolean "is_default",          null: false, default: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end
  add_index "addresses", ["party_id", "kind", "is_default"], unique: true, where: "is_default"
  add_index "addresses", ["party_id"]
  add_foreign_key "addresses", "parties", column: "party_id"

  # Social profiles & websites
  create_table "social_profiles", force: :cascade do |t|
    t.bigint "party_id",            null: false
    t.string "network",             null: false      # linkedin | facebook | ...
    t.string "url",                 null: false      # for both persons & orgs 【1:25-L27】
    t.string "username"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end
  add_index "social_profiles", ["party_id", "network"], unique: true
  add_foreign_key "social_profiles", "parties", column: "party_id"

  create_table "websites", force: :cascade do |t|
    t.bigint "party_id",            null: false      # primarily organizations 【1:27-L27】
    t.string "url",                 null: false
    t.boolean "primary",            null: false, default: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end
  add_index "websites", ["party_id", "primary"], unique: true, where: "primary"
  add_foreign_key "websites", "parties", column: "party_id"

  # Generic relationships between parties (employee, holding, peer, etc.)
  create_table "relationships", force: :cascade do |t|
    t.bigint "from_party_id",       null: false  # e.g., person or parent org
    t.bigint "to_party_id",         null: false  # e.g., organization or child org
    t.string "relationship_type",   null: false  # employee | holding | custom 【4:25-L25】【1:1-L3】
    t.string "role_title"                           # for employee: Director, Accountant... 【4:31-L31】
    t.boolean "is_primary",         null: false, default: false # main contact for org 【4:33-L33】
    t.date   "valid_from"                           # employment start
    t.date   "valid_to"                             # employment end (job change wizard)
    t.jsonb  "metadata",            null: false, default: {}
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end
  add_index "relationships", ["from_party_id"]
  add_index "relationships", ["to_party_id"]
  add_foreign_key "relationships", "parties", column: "from_party_id"
  add_foreign_key "relationships", "parties", column: "to_party_id"
  # exactly one primary contact per organization for employee relations 【4:33-L33】
  add_index "relationships", ["to_party_id"], unique: true,
            where: "relationship_type = 'employee' AND is_primary"

  # Consents history
  create_table "consents", force: :cascade do |t|
    t.bigint  "party_id",           null: false
    t.string  "consent_type",       null: false
    t.string  "status",             null: false      # given | revoked
    t.datetime "granted_at"
    t.datetime "revoked_at"
    t.string  "source"
    t.jsonb   "metadata",           null: false, default: {}
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end
  add_index "consents", ["party_id", "consent_type"], unique: true, where: "status = 'given'"
  add_foreign_key "consents", "parties
