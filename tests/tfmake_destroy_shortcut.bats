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
  bash tfmake cleanup
}

@test "tfmake destroy" {
  bash tfmake destroy

    # directory structure
  assert_dir_exist ".tfmake"

  assert_dir_exist ".tfmake/destroy"
  assert_dir_exist ".tfmake/destroy/logs"
  assert_dir_exist ".tfmake/destroy/outputs"

  assert_dir_exist ".tfmake/destroy/store"
  assert_dir_exist ".tfmake/destroy/store/modules"
  assert_dir_exist ".tfmake/destroy/store/dependencies"

  # kv store
  store::basepath .tfmake/destroy/store

  store::use modules

  run kv::get A
  assert_output true

  run kv::get B
  assert_output true

  run kv::get C
  assert_output true

  store::use dependencies

  run kv::get B
  assert_output C

  # Makefile
  assert_file_exist ".tfmake/destroy/Makefile"

  # run
  assert_file_exist ".tfmake/destroy/outputs/visited"
  run cat ".tfmake/destroy/outputs/visited"

  assert_output << EOF
B
C
A
EOF

  # terraform logs
  for key in $(util::splitlines "$(kv::keys)"); do
    assert_file_exist ".tfmake/destroy/logs/${key}/init.log"
    assert_file_exist ".tfmake/destroy/logs/${key}/destroy.log"
  done
}

@test "tfmake graph" {
  bash tfmake graph
  assert_file_exist ".tfmake/destroy/outputs/mermaid.md"
}

@test "tfmake summary" {
  bash tfmake summary
  assert_file_exist ".tfmake/destroy/outputs/summary.md"
}

@test "tfmake summary (without outputs)" {
  run bash tfmake summary --no-outputs
  assert_file_exist ".tfmake/destroy/outputs/summary.md"
}

@test "tfmake summary (with title)" {
  export TFMAKE_SUMMARY_TITLE="Basic Project Destroy"
  bash tfmake summary
  assert_file_contains ".tfmake/destroy/outputs/summary.md" "${TFMAKE_SUMMARY_TITLE}"
}

@test "tfmake gh-pr-comment (no --number)" {
  run bash tfmake gh-pr-comment
  assert_output "Missing '--number' option."
}

@test "tfmake gh-pr-comment (with --dry-run)" {
  size=$(wc -c ".tfmake/destroy/outputs/summary.md" | awk '{print $1-1}')
  export MAX_COMMENT_SIZE=${size}

  run bash tfmake gh-pr-comment --dry-run
  assert_file_exist ".tfmake/destroy/outputs/fragment-1.md"
  assert_file_exist ".tfmake/destroy/outputs/fragment-2.md"
}
