#!/usr/bin/env bash

# shellcheck source=/dev/null
source "${BATS_TESTS_DIR}/../usr/local/include/tfmake/util.sh"
source "${BATS_TESTS_DIR}/../usr/local/include/tfmake/store.sh"

function create_store() {
  store::basepath "${BATS_TESTS_DIR}/${1}"
}

function delete_store() {
  rm -rf "${STORE_PATH:?}"
}
