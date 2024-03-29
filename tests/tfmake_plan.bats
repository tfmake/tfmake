setup() {
  load _helper
  load _store
  load _tfmake

  bats_load_library "bats-support"
  bats_load_library "bats-assert"
  bats_load_library "bats-file"

  cd_terraform_modules_path
}

@test "tfmake context" {
  bash tfmake context plan
}

@test "tfmake cleanup (1st)" {
  bash tfmake cleanup
}

@test "tfmake makefile (before init)" {
  run bash tfmake makefile
  assert_output "Run 'tfmake init' first."
}

@test "tfmake init" {
  bash tfmake init

  # directory structure
  assert_dir_exist ".tfmake"

  assert_dir_exist ".tfmake/plan"
  assert_dir_exist ".tfmake/plan/logs"
  assert_dir_exist ".tfmake/plan/outputs"

  assert_dir_exist ".tfmake/plan/store"
  assert_dir_exist ".tfmake/plan/store/modules"
  assert_dir_exist ".tfmake/plan/store/dependencies"

  # kv store
  store::basepath .tfmake/plan/store

  store::use modules

  run kv::get A
  assert_output true

  run kv::get B
  assert_output true

  store::use dependencies

  run kv::get B
  assert_output A
}

@test "tfmake cleanup (2nd)" {
  bash tfmake cleanup
}

@test "tfmake init (with -i)" {
  bash tfmake init -i C

  # directory structure
  assert_dir_exist ".tfmake"

  assert_dir_exist ".tfmake/plan"
  assert_dir_exist ".tfmake/plan/logs"
  assert_dir_exist ".tfmake/plan/outputs"

  assert_dir_exist ".tfmake/plan/store"
  assert_dir_exist ".tfmake/plan/store/modules"
  assert_dir_exist ".tfmake/plan/store/dependencies"
  assert_dir_exist ".tfmake/plan/store/ignore"

  # kv store
  store::basepath .tfmake/plan/store

  store::use modules

  run kv::get A
  assert_output true

  run kv::get B
  assert_output true

  store::use ignore

  run kv::get C
  assert_output true

  store::use dependencies

  run kv::get B
  assert_output A
}

@test "tfmake run (before makefile)" {
  run bash tfmake run
  assert_output "Run 'tfmake makefile' first."
}

@test "tfmake makefile" {
  bash tfmake makefile
  assert_file_exist ".tfmake/plan/Makefile"
}

@test "tfmake makefile (local log grouping on)" {
  bash tfmake makefile

  run util::global_config_get "cicd"
  assert_output "local"
}

@test "tfmake makefile (github log grouping on)" {
  export GITHUB_ACTIONS=true

  bash tfmake makefile

  run util::global_config_get "cicd"
  assert_output "github"
}

@test "tfmake makefile (github log grouping off)" {
  export GITHUB_ACTIONS=true
  export TFMAKE_LOG_GROUPING=false

  bash tfmake makefile

  run util::global_config_get "cicd"
  assert_output "local"
}

@test "tfmake graph (before run)" {
  run bash tfmake graph
  assert_output "Run 'tfmake run' first."
}

@test "tfmake summary (before run)" {
  run bash tfmake summary
  assert_output "Run 'tfmake run' first."
}

@test "tfmake touch" {
  bash tfmake touch -f "A/main.tf A/terraform.tfvars"

  # kv store
  store::basepath .tfmake/plan/store
  store::use modified

  run util::splitlines "$(kv::keys)"
  assert_output "A/main.tf A/terraform.tfvars"
}

@test "tfmake touch (repeated -f)" {
  bash tfmake touch -f A/main.tf -f A/terraform.tfvars

  # kv store
  store::basepath .tfmake/plan/store
  store::use modified

  run util::splitlines "$(kv::keys)"
  assert_output "A/main.tf A/terraform.tfvars"
}

@test "tfmake run" {
  bash tfmake run

  # kv store
  store::basepath .tfmake/plan/store

  store::use visited

  run util::splitlines "$(kv::keys)"
  assert_output "A B"

  # terraform logs
  for key in $(util::splitlines "$(kv::keys)"); do
    assert_file_exist ".tfmake/plan/logs/${key}/init.log"
    assert_file_exist ".tfmake/plan/logs/${key}/plan.log"
  done
}

@test "tfmake run (second time)" {
  run bash tfmake run
  assert_output --partial "make: Nothing to be done for"
}

@test "tfmake run (all)" {
  bash tfmake run --all

  # kv store
  store::basepath .tfmake/plan/store

  store::use visited

  run util::splitlines "$(kv::keys)"
  assert_output "A B"

  # terraform logs
  for key in $(util::splitlines "$(kv::keys)"); do
    assert_file_exist ".tfmake/plan/logs/${key}/init.log"
    assert_file_exist ".tfmake/plan/logs/${key}/plan.log"
  done
}

@test "tfmake run (dry run)" {
  bash tfmake touch -f A/main.tf
  run bash tfmake run --dry-run
  assert_output --partial - << EOF
A
B
EOF

  bash tfmake touch -f B/main.tf
  run bash tfmake run --dry-run
  assert_output --partial B
}

@test "tfmake gh-pr-comment (before summary)" {
  run bash tfmake gh-pr-comment --number 1 --dry-run
  assert_output "Run 'tfmake summary' first."
}

@test "tfmake graph" {
  bash tfmake graph
  assert_file_exist ".tfmake/plan/outputs/mermaid.md"
}

@test "tfmake summary" {
  bash tfmake summary
  assert_file_exist ".tfmake/plan/outputs/summary.md"
}

@test "tfmake summary (without outputs)" {
  run bash tfmake summary --no-outputs
  assert_file_exist ".tfmake/plan/outputs/summary.md"
}

@test "tfmake summary (with title)" {
  export TFMAKE_SUMMARY_TITLE="Basic Project Plan"
  bash tfmake summary
  assert_file_contains ".tfmake/plan/outputs/summary.md" "${TFMAKE_SUMMARY_TITLE}"
}

@test "tfmake gh-pr-comment (no --number)" {
  run bash tfmake gh-pr-comment
  assert_output "Missing '--number' option."
}

@test "tfmake gh-pr-comment (with --dry-run)" {
  size=$(wc -c ".tfmake/plan/outputs/summary.md" | awk '{print $1-1}')
  export MAX_COMMENT_SIZE=${size}

  run bash tfmake gh-pr-comment --dry-run
  assert_file_exist ".tfmake/plan/outputs/fragment-1.md"
  assert_file_exist ".tfmake/plan/outputs/fragment-2.md"
}
