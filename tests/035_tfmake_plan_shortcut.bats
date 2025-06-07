setup() {
  load _helper
  load _store
  load _tfmake

  bats_load_library "bats-support"
  bats_load_library "bats-assert"
  bats_load_library "bats-file"

  export TFMAKE_DATA_DIR=".tfmake/035_tfmake_plan_shortcut"

  cd_terraform_modules_path
}

@test "tfmake cleanup" {
  bash tfmake cleanup
}

@test "tfmake plan" {
  bash tfmake plan

  # directory structure
  assert_dir_exist ".tfmake"

  assert_dir_exist "${TFMAKE_DATA_DIR}/plan"
  assert_dir_exist "${TFMAKE_DATA_DIR}/plan/logs"
  assert_dir_exist "${TFMAKE_DATA_DIR}/plan/outputs"

  assert_dir_exist "${TFMAKE_DATA_DIR}/plan/store"
  assert_dir_exist "${TFMAKE_DATA_DIR}/plan/store/modules"
  assert_dir_exist "${TFMAKE_DATA_DIR}/plan/store/dependencies"

  # kv store
  store::basepath ${TFMAKE_DATA_DIR}/plan/store

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
  assert_file_exist "${TFMAKE_DATA_DIR}/plan/Makefile"

  # run
  assert_file_exist "${TFMAKE_DATA_DIR}/plan/outputs/visited"
  run cat "${TFMAKE_DATA_DIR}/plan/outputs/visited"

  assert_output << EOF
A
C
B
EOF

  # terraform logs
  for key in $(util::splitlines "$(kv::keys)"); do
    assert_file_exist "${TFMAKE_DATA_DIR}/plan/logs/${key}/init.log"
    assert_file_exist "${TFMAKE_DATA_DIR}/plan/logs/${key}/plan.log"
  done
}

@test "tfmake graph" {
  bash tfmake graph
  assert_file_exist "${TFMAKE_DATA_DIR}/plan/outputs/mermaid.md"
}

@test "tfmake summary" {
  bash tfmake summary
  assert_file_exist "${TFMAKE_DATA_DIR}/plan/outputs/summary.md"
}

@test "tfmake summary (without outputs)" {
  run bash tfmake summary --no-outputs
  assert_file_exist "${TFMAKE_DATA_DIR}/plan/outputs/summary.md"
}

@test "tfmake summary (with title)" {
  export TFMAKE_SUMMARY_TITLE="Basic Project Plan"
  bash tfmake summary
  assert_file_contains "${TFMAKE_DATA_DIR}/plan/outputs/summary.md" "${TFMAKE_SUMMARY_TITLE}"
}

@test "tfmake gh-pr-comment (no --number)" {
  run bash tfmake gh-pr-comment
  assert_output "Missing '--number' option."
}

@test "tfmake gh-pr-comment (with --dry-run)" {
  size=$(wc -c "${TFMAKE_DATA_DIR}/plan/outputs/summary.md" | awk '{print $1-1}')
  export MAX_COMMENT_SIZE=${size}

  run bash tfmake gh-pr-comment --dry-run
  assert_file_exist "${TFMAKE_DATA_DIR}/plan/outputs/fragment-1.md"
  assert_file_exist "${TFMAKE_DATA_DIR}/plan/outputs/fragment-2.md"
}
