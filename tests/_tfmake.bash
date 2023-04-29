#!/usr/bin/env bash

# shellcheck source=/dev/null
source "${BATS_TESTS_DIR}/../usr/local/include/tfmake/util.sh"
source "${BATS_TESTS_DIR}/../usr/local/include/tfmake/store.sh"

TF_MODULES_PATH="${BATS_TESTS_DIR}/terraform/basic"

function cd_terraform_modules_path() {
  cd "${TF_MODULES_PATH}" || exit
}
