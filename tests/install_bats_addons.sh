#!/usr/bin/env bash

BATS_TESTS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

BATS_SUPPORT_TAG="v0.3.0"
BATS_ASSERT_TAG="v2.1.0"
BATS_FILE_TAG="v0.4.0"

if [[ ! -f "${BATS_TESTS_DIR}"/bats/addons/bats-support/load.bash ]]; then
  git clone --depth 1 --branch ${BATS_SUPPORT_TAG} https://github.com/bats-core/bats-support.git "${BATS_TESTS_DIR}"/bats/addons/bats-support
fi

if [[ ! -f "${BATS_TESTS_DIR}"/bats/addons/bats-assert/load.bash ]]; then
  git clone --depth 1 --branch ${BATS_ASSERT_TAG} https://github.com/bats-core/bats-assert.git "${BATS_TESTS_DIR}"/bats/addons/bats-assert
fi

if [[ ! -f "${BATS_TESTS_DIR}"/bats/addons/bats-file/load.bash ]]; then
  git clone --depth 1 --branch ${BATS_FILE_TAG} https://github.com/bats-core/bats-file.git "${BATS_TESTS_DIR}"/bats/addons/bats-file
fi
