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
  bash tfmake cleanup --apply
}

@test "tfmake makefile (before init)" {
  run bash tfmake makefile --apply
  assert_output ">>> Run 'tfmake init --apply' first."
}

@test "tfmake init" {
  bash tfmake init --apply

  # directory structure
  assert_dir_exist ".tfmake"

  assert_dir_exist ".tfmake/apply"
  assert_dir_exist ".tfmake/apply/logs"
  assert_dir_exist ".tfmake/apply/outputs"

  assert_dir_exist ".tfmake/apply/store"
  assert_dir_exist ".tfmake/apply/store/modules"
  assert_dir_exist ".tfmake/apply/store/dependencies"

  # kv store
  store::basepath .tfmake/apply/store

  run kv::get modules A
  assert_output true

  run kv::get modules B
  assert_output true

  run kv::get dependencies B
  assert_output A
}

@test "tfmake apply (before makefile)" {
  run bash tfmake apply
  assert_output ">>> Run 'tfmake makefile --apply' first."
}

@test "tfmake makefile" {
  bash tfmake makefile --apply
  assert_file_exist ".tfmake/apply/Makefile"
}

@test "tfmake mermaid (before apply)" {
  run bash tfmake mermaid --apply
  assert_output ">>> Run 'tfmake apply' first."
}

@test "tfmake summary (before apply)" {
  run bash tfmake summary --apply --no-diagram
  assert_output ">>> Run 'tfmake apply' first."
}

@test "tfmake apply" {
  bash tfmake touch --files A/main.tf
  bash tfmake apply > /dev/null

  # kv store
  store::basepath .tfmake/apply/store

  run utils::splitlines "$(kv::keys modules)"
  assert_output "A B"

  # terraform logs
  for key in $(utils::splitlines "$(kv::keys modules)"); do
    assert_file_exist ".tfmake/apply/logs/${key}/init.log"
    assert_file_exist ".tfmake/apply/logs/${key}/apply.log"
  done
}

@test "tfmake summary (before mermaid)" {
  run bash tfmake summary --apply
  assert_output ">>> Run 'tfmake mermaid --apply' first."
}

@test "tfmake gh-pr-comment (before summary)" {
  run bash tfmake gh-pr-comment --apply --number 1 --dry-run
  assert_output ">>> Run 'tfmake summary --apply' first."
}

@test "tfmake summary (without mermaid)" {
  run bash tfmake summary --apply --no-diagram
  assert_file_exist ".tfmake/apply/outputs/summary.md"
}

@test "tfmake mermaid" {
  bash tfmake mermaid --apply
  assert_file_exist ".tfmake/apply/outputs/mermaid.md"
}

@test "tfmake summary" {
  bash tfmake summary --apply
  assert_file_exist ".tfmake/apply/outputs/summary.md"
}

@test "tfmake summary (without outputs)" {
  run bash tfmake summary --apply --no-outputs
  assert_file_exist ".tfmake/apply/outputs/summary.md"
}

@test "tfmake summary (title)" {
  export SUMMARY_TITLE="Basic Project Apply"
  bash tfmake summary --apply
  assert_file_contains ".tfmake/apply/outputs/summary.md" "${SUMMARY_TITLE}"
}

@test "tfmake gh-pr-comment (no --plan/--apply)" {
  run bash tfmake gh-pr-comment --number 1
  assert_output ">>> Missing '--plan' or '--apply' option."
}

@test "tfmake gh-pr-comment (no --number)" {
  run bash tfmake gh-pr-comment --apply
  assert_output ">>> Missing '--number' option."
}

@test "tfmake gh-pr-comment (with --dry-run)" {
  size=$(wc -c ".tfmake/apply/outputs/summary.md" | awk '{print $1-1}')
  export MAX_COMMENT_SIZE=${size}

  run bash tfmake gh-pr-comment --apply --dry-run
  assert_file_exist ".tfmake/apply/outputs/fragment-0.md"
  assert_file_exist ".tfmake/apply/outputs/fragment-1.md"
}
