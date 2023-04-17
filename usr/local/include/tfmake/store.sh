#!/usr/bin/env bash

function hash() {
  printf "%s" "${1}" | md5sum | cut -d' ' -f1
}

function store::basepath() {
  mkdir -p "${1}"
  export STORE_PATH=${1}
}

function store::use() {
  KV_PATH="${STORE_PATH}/${1-}"

  mkdir -p "${KV_PATH}"
  touch "${KV_PATH}/keys"

  export KV_PATH
}

function kv::set() {
  key=${1}; value=${2};

  hash=$(hash "${key}")
  printf "%s" "${value}" > "${KV_PATH}/${hash}"

  grep -q "${key}" "${KV_PATH}/keys"
  if [[ $? -ne 0 ]]; then
    printf "%s\n" "${key}" >> "${KV_PATH}/keys"
  fi
}

function kv::get() {
  key=${1}

  hash=$(hash "${key}")
  if [[ -f "${KV_PATH}/${hash}" ]]; then
    cat "${KV_PATH}/${hash}"
  fi
}

function kv::keys() {
  if [[ -f "${KV_PATH}/keys" ]]; then
    cat "${KV_PATH}/keys"
  fi
}
