#!/usr/bin/env bash

BATS_TESTS_DIR=$(cd "$(dirname "${BATS_TEST_FILENAME[0]}")" &>/dev/null && pwd -P)
PATH="$BATS_TESTS_DIR/../usr/local/bin/:$PATH"

# shellcheck disable=SC2034
BATS_LIB_PATH="${BATS_TESTS_DIR}/bats/addons:BATS_LIB_PATH"
