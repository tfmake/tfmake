setup() {
  load _helper
  load _store
  load _tfmake

  bats_load_library "bats-support"
  bats_load_library "bats-assert"
  bats_load_library "bats-file"

  cd_terraform_modules_path
}

@test "tfmake cleanup" {
  bash tfmake cleanup --plan
}

@test "tfmake makefile (before init)" {
  run bash tfmake makefile --plan
  assert_output ">>> Run 'tfmake init --plan' first."
}

@test "tfmake init" {
  bash tfmake init --plan

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

@test "tfmake plan (before makefile)" {
  run bash tfmake plan
  assert_output ">>> Run 'tfmake makefile --plan' first."
}

@test "tfmake makefile" {
  bash tfmake makefile --plan
  assert_file_exist ".tfmake/plan/Makefile"
}

@test "tfmake mermaid (before plan)" {
  run bash tfmake mermaid --plan
  assert_output ">>> Run 'tfmake plan' first."
}

@test "tfmake summary (before plan)" {
  run bash tfmake summary --plan --no-diagram
  assert_output ">>> Run 'tfmake plan' first."
}

@test "tfmake plan" {
  bash tfmake touch --files A/main.tf
  bash tfmake plan > /dev/null

  # kv store
  store::basepath .tfmake/plan/store

  store::use modules

  run utils::splitlines "$(kv::keys)"
  assert_output "A B"

  # terraform logs
  for key in $(utils::splitlines "$(kv::keys)"); do
    assert_file_exist ".tfmake/plan/logs/${key}/init.log"
    assert_file_exist ".tfmake/plan/logs/${key}/plan.log"
  done
}

@test "tfmake summary (before mermaid)" {
  run bash tfmake summary --plan
  assert_output ">>> Run 'tfmake mermaid --plan' first."
}

@test "tfmake gh-pr-comment (before summary)" {
  run bash tfmake gh-pr-comment --plan --number 1 --dry-run
  assert_output ">>> Run 'tfmake summary --plan' first."
}

@test "tfmake summary (without mermaid)" {
  run bash tfmake summary --plan --no-diagram
  assert_file_exist ".tfmake/plan/outputs/summary.md"
}

@test "tfmake mermaid" {
  bash tfmake mermaid --plan
  assert_file_exist ".tfmake/plan/outputs/mermaid.md"
}

@test "tfmake summary" {
  bash tfmake summary --plan
  assert_file_exist ".tfmake/plan/outputs/summary.md"
}

@test "tfmake summary (without outputs)" {
  run bash tfmake summary --plan --no-outputs
  assert_file_exist ".tfmake/plan/outputs/summary.md"
}

@test "tfmake summary (with title)" {
  export SUMMARY_TITLE="Basic Project Plan"
  bash tfmake summary --plan
  assert_file_contains ".tfmake/plan/outputs/summary.md" "${SUMMARY_TITLE}"
}

@test "tfmake gh-pr-comment (no --plan/--apply)" {
  run bash tfmake gh-pr-comment --number 1
  assert_output ">>> Missing '--plan' or '--apply' option."
}

@test "tfmake gh-pr-comment (no --number)" {
  run bash tfmake gh-pr-comment --plan
  assert_output ">>> Missing '--number' option."
}

@test "tfmake gh-pr-comment (with --dry-run)" {
  size=$(wc -c ".tfmake/plan/outputs/summary.md" | awk '{print $1-1}')
  export MAX_COMMENT_SIZE=${size}

  run bash tfmake gh-pr-comment --plan --dry-run
  assert_file_exist ".tfmake/plan/outputs/fragment-0.md"
  assert_file_exist ".tfmake/plan/outputs/fragment-1.md"
}
