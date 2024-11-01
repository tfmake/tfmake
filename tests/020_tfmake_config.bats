setup() {
  load _helper
  load _store
  load _tfmake

  bats_load_library "bats-support"
  bats_load_library "bats-assert"
  bats_load_library "bats-file"

  cd_terraform_modules_path
}

@test "tfmake config" {
  bash tfmake config --set context plan
  run bash tfmake config --get context
  assert_output "plan"

  bash tfmake config --set context apply
  run bash tfmake config --get context
  assert_output "apply"
}

@test "tfmake config --get (missing)" {
  run bash tfmake config --get
  assert_output "Missing config key."
}

@test "tfmake context" {
  bash tfmake context plan
  run bash tfmake context
  assert_output "plan"

  run bash tfmake config --get context
  assert_output "plan"
}
