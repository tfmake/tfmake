setup() {
  load _helper
  load _store
  load _tfmake

  bats_load_library "bats-support"
  bats_load_library "bats-assert"
  bats_load_library "bats-file"

  export TFMAKE_DATA_DIR=".tfmake/0065_tfmake_validate_shortcut"

  cd_terraform_modules_path
}

@test "tfmake cleanup" {
  bash tfmake cleanup
}

@test "tfmake validate (failure)" {
  add_invalid_module E

  run bash tfmake validate
  assert_failure

  remove_invalid_module E

  # directory structure
  assert_dir_exist ".tfmake"

  assert_dir_exist "${TFMAKE_DATA_DIR}/validate"
  assert_dir_exist "${TFMAKE_DATA_DIR}/validate/logs"
  assert_dir_exist "${TFMAKE_DATA_DIR}/validate/outputs"

  assert_dir_exist "${TFMAKE_DATA_DIR}/validate/store"
  assert_dir_exist "${TFMAKE_DATA_DIR}/validate/store/modules"
  assert_dir_exist "${TFMAKE_DATA_DIR}/validate/store/dependencies"

  # kv store
  store::basepath ${TFMAKE_DATA_DIR}/validate/store

  store::use modules

  run kv::get A
  assert_output true

  run kv::get B
  assert_output true

  run kv::get C
  assert_output true

  run kv::get E
  assert_output true

  store::use dependencies

  run kv::get B
  assert_output C

  # Makefile
  assert_file_exist "${TFMAKE_DATA_DIR}/validate/Makefile"

  # run
  assert_file_exist "${TFMAKE_DATA_DIR}/validate/outputs/visited"

  assert_file_exist "${TFMAKE_DATA_DIR}/validate/logs/signpost.log"

  run cat  "${TFMAKE_DATA_DIR}/validate/logs/signpost.log"
  assert_output --partial "Error"

  # terraform logs
  store::use visited

  for key in $(util::splitlines "$(kv::keys)"); do
    assert_file_exist "${TFMAKE_DATA_DIR}/validate/logs/${key}/init.log"
    assert_file_exist "${TFMAKE_DATA_DIR}/validate/logs/${key}/validate.log"
  done
}

@test "tfmake validate (success)" {
  bash tfmake validate

    # directory structure
  assert_dir_exist ".tfmake"

  assert_dir_exist "${TFMAKE_DATA_DIR}/validate"
  assert_dir_exist "${TFMAKE_DATA_DIR}/validate/logs"
  assert_dir_exist "${TFMAKE_DATA_DIR}/validate/outputs"

  assert_dir_exist "${TFMAKE_DATA_DIR}/validate/store"
  assert_dir_exist "${TFMAKE_DATA_DIR}/validate/store/modules"
  assert_dir_exist "${TFMAKE_DATA_DIR}/validate/store/dependencies"

  # kv store
  store::basepath ${TFMAKE_DATA_DIR}/validate/store

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
  assert_file_exist "${TFMAKE_DATA_DIR}/validate/Makefile"

  # run
  assert_file_exist "${TFMAKE_DATA_DIR}/validate/outputs/visited"
  run cat "${TFMAKE_DATA_DIR}/validate/outputs/visited"

  assert_output << EOF
B
C
A
EOF

  # terraform logs
  for key in $(util::splitlines "$(kv::keys)"); do
    assert_file_exist "${TFMAKE_DATA_DIR}/validate/logs/${key}/init.log"
    assert_file_exist "${TFMAKE_DATA_DIR}/validate/logs/${key}/validate.log"
  done
}

@test "tfmake graph" {
  bash tfmake graph
  assert_file_exist "${TFMAKE_DATA_DIR}/validate/outputs/mermaid.md"
}

@test "tfmake summary" {
  bash tfmake summary
  assert_file_exist "${TFMAKE_DATA_DIR}/validate/outputs/summary.md"
}

@test "tfmake summary (without outputs)" {
  run bash tfmake summary --no-outputs
  assert_file_exist "${TFMAKE_DATA_DIR}/validate/outputs/summary.md"
}

@test "tfmake summary (with title)" {
  export TFMAKE_SUMMARY_TITLE="Basic Project validate"
  bash tfmake summary
  assert_file_contains "${TFMAKE_DATA_DIR}/validate/outputs/summary.md" "${TFMAKE_SUMMARY_TITLE}"
}

@test "tfmake gh-pr-comment (no --number)" {
  run bash tfmake gh-pr-comment
  assert_output "Missing '--number' option."
}

@test "tfmake gh-pr-comment (with --dry-run)" {
  size=$(wc -c "${TFMAKE_DATA_DIR}/validate/outputs/summary.md" | awk '{print $1-1}')
  export MAX_COMMENT_SIZE=${size}

  run bash tfmake gh-pr-comment --dry-run
  assert_file_exist "${TFMAKE_DATA_DIR}/validate/outputs/fragment-1.md"
  assert_file_exist "${TFMAKE_DATA_DIR}/validate/outputs/fragment-2.md"
}
