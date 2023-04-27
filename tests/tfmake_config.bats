setup() {
  load _helper
  load _store
  load _tfmake

  bats_load_library "bats-support"
  bats_load_library "bats-assert"
  bats_load_library "bats-file"

  cd_terraform_modules_path
}

@test "tfmake config --set" {
  run bash tfmake config --set context plan
  assert_output "context=plan"

  run bash tfmake config --set context apply
  assert_output "context=apply"
}

@test "tfmake config --get (missing)" {
  run bash tfmake config --get
  assert_output ">>> Missing config key."
}

@test "tfmake config --get" {
  bash tfmake config --set color blue
  run bash tfmake config --get color
  assert_output "blue"
}
