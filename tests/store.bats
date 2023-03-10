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

@test "store::kv" {
  store::kv modules

  assert_dir_exist "${STORE_PATH}/modules"
  assert_file_empty "${STORE_PATH}/modules/keys"
}

@test "kv::set" {
  store::kv modules

  run kv::set "terraform/network/main.tf" true
  hash=$(hash "terraform/network/main.tf")

  assert_file_contains "${STORE_PATH}/modules/keys" "terraform/network/main.tf"
  assert_file_contains "${STORE_PATH}/modules/${hash}" true
}

@test "kv::get" {
  store::kv modules

  run kv::set "terraform/network/main.tf" true
  run kv::get "terraform/network/main.tf"

  assert_output true
}

@test "kv::keys" {
  store::kv letters

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

@test "kv::set  (explicit kv store)" {
  run kv::set visited "terraform/network/main.tf" true
  hash=$(hash "terraform/network/main.tf")

  assert_file_contains "${STORE_PATH}/visited/keys" "terraform/network/main.tf"
  assert_file_contains "${STORE_PATH}/visited/${hash}" true
}

@test "kv::get  (explicit kv store)" {
  run kv::set visited "terraform/network/main.tf" true
  run kv::get visited "terraform/network/main.tf"
  assert_output true
}

@test "kv::keys (explicit kv store)" {
  run kv::set letters a 1
  run kv::set letters b 2
  run kv::set letters c 3

  run kv::keys letters
  assert_output - << EOF
a
b
c
EOF
}

@test "kv::get  (missing key)" {
  store::kv modules

  run kv::get "missing key"
  assert_output ""
}


@test "kv::keys (split lines)" {
  store::kv letters

  run kv::set a 1
  run kv::set b 2
  run kv::set c 3

  run utils::splitlines "$(kv::keys)"
  assert_output "a b c"
}
