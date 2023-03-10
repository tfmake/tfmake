#!/usr/bin/env bash

# shellcheck disable=SC2034
BATS_LIB_PATH="/opt/homebrew/lib:${BATS_LIB_PATH}"

BATS_TESTS_DIR=$(cd "$(dirname "${BATS_TEST_FILENAME[0]}")" &>/dev/null && pwd -P)
PATH="$BATS_TESTS_DIR/../usr/local/bin/:$PATH"
