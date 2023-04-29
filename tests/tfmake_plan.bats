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
}

@test "tfmake cleanup" {
  bash tfmake cleanup
}

@test "tfmake makefile (before init)" {
  run bash tfmake makefile
  assert_output ">>> Run 'tfmake init' first."
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

@test "tfmake run (before makefile)" {
  run bash tfmake run
  assert_output ">>> Run 'tfmake makefile' first."
}

@test "tfmake makefile" {
  bash tfmake makefile
  assert_file_exist ".tfmake/plan/Makefile"
}

@test "tfmake mermaid (before run)" {
  run bash tfmake mermaid
  assert_output ">>> Run 'tfmake run' first."
}

@test "tfmake summary (before run)" {
  run bash tfmake summary --no-diagram
  assert_output ">>> Run 'tfmake run' first."
}

@test "tfmake touch" {
  bash tfmake touch -f "A/main.tf A/terraform.tfvars"

  # kv store
  store::basepath .tfmake/plan/store
  store::use modified

  run utils::splitlines "$(kv::keys)"
  assert_output "A/main.tf A/terraform.tfvars"
}

@test "tfmake touch (repeated -f)" {
  bash tfmake touch -f A/main.tf -f A/terraform.tfvars

  # kv store
  store::basepath .tfmake/plan/store
  store::use modified

  run utils::splitlines "$(kv::keys)"
  assert_output "A/main.tf A/terraform.tfvars"
}

@test "tfmake run" {
  bash tfmake run > /dev/null

  # kv store
  store::basepath .tfmake/plan/store

  store::use visited

  run utils::splitlines "$(kv::keys)"
  assert_output "A B"

  # terraform logs
  for key in $(utils::splitlines "$(kv::keys)"); do
    assert_file_exist ".tfmake/plan/logs/${key}/init.log"
    assert_file_exist ".tfmake/plan/logs/${key}/plan.log"
  done
}

@test "tfmake run (second time)" {
  run bash tfmake run > /dev/null
  assert_output --partial "make: Nothing to be done for"
}

@test "tfmake run (all)" {
  bash tfmake run --all > /dev/null

  # kv store
  store::basepath .tfmake/plan/store

  store::use visited

  run utils::splitlines "$(kv::keys)"
  assert_output "A B"

  # terraform logs
  for key in $(utils::splitlines "$(kv::keys)"); do
    assert_file_exist ".tfmake/plan/logs/${key}/init.log"
    assert_file_exist ".tfmake/plan/logs/${key}/plan.log"
  done
}

@test "tfmake run (dry run)" {
  bash tfmake touch -f A/main.tf
  run bash tfmake run --dry-run
  assert_output - << EOF
A
B
EOF

  bash tfmake touch -f B/main.tf
  run bash tfmake run --dry-run
  assert_output B
}

@test "tfmake summary (before mermaid)" {
  run bash tfmake summary
  assert_output ">>> Run 'tfmake mermaid' first."
}

@test "tfmake gh-pr-comment (before summary)" {
  run bash tfmake gh-pr-comment --number 1 --dry-run
  assert_output ">>> Run 'tfmake summary' first."
}

@test "tfmake summary (without mermaid)" {
  run bash tfmake summary --no-diagram
  assert_file_exist ".tfmake/plan/outputs/summary.md"
}

@test "tfmake mermaid" {
  bash tfmake mermaid
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
  export SUMMARY_TITLE="Basic Project Plan"
  bash tfmake summary
  assert_file_contains ".tfmake/plan/outputs/summary.md" "${SUMMARY_TITLE}"
}

@test "tfmake gh-pr-comment (no --number)" {
  run bash tfmake gh-pr-comment
  assert_output ">>> Missing '--number' option."
}

@test "tfmake gh-pr-comment (with --dry-run)" {
  size=$(wc -c ".tfmake/plan/outputs/summary.md" | awk '{print $1-1}')
  export MAX_COMMENT_SIZE=${size}

  run bash tfmake gh-pr-comment --dry-run
  assert_file_exist ".tfmake/plan/outputs/fragment-0.md"
  assert_file_exist ".tfmake/plan/outputs/fragment-1.md"
}
