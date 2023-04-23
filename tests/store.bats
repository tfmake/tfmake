setup() {
  load _helper
  load _store

  bats_load_library "bats-support"
  bats_load_library "bats-assert"
  bats_load_library "bats-file"

  create_store testdb
}

function teardown() {
  delete_store
}

@test "store::basepath" {
  assert_dir_exist "${STORE_PATH}"
}

@test "store::use" {
  store::use modules

  assert_dir_exist "${STORE_PATH}/modules"
  assert_file_empty "${STORE_PATH}/modules/keys"
}

@test "store::truncate" {
  store::truncate modified

  assert_dir_exist "${STORE_PATH}/modified"
  assert_file_empty "${STORE_PATH}/modified/keys"

  run kv::set "terraform/network/main.tf" true
  run kv::get "terraform/network/main.tf"
  assert_output true

  store::truncate modified
  assert_file_empty "${STORE_PATH}/modified/keys"
}

@test "kv::set" {
  store::use modules

  run kv::set "terraform/network/main.tf" true
  hash=$(hash "terraform/network/main.tf")

  assert_file_contains "${STORE_PATH}/modules/keys" "terraform/network/main.tf"
  assert_file_contains "${STORE_PATH}/modules/${hash}" true
}

@test "kv::get" {
  store::use modules

  run kv::set "terraform/network/main.tf" true
  run kv::get "terraform/network/main.tf"

  assert_output true
}

@test "kv::keys" {
  store::use letters

  run kv::set a 1
  run kv::set b 2
  run kv::set c 3

  run kv::keys
  assert_output - << EOF
a
b
c
EOF
}

@test "kv::get (missing key)" {
  store::use modules

  run kv::get "missing key"
  assert_output ""
}

@test "kv::keys (split lines)" {
  store::use letters

  run kv::set a 1
  run kv::set b 2
  run kv::set c 3

  run utils::splitlines "$(kv::keys)"
  assert_output "a b c"
}
