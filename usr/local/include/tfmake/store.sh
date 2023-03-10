#!/usr/bin/env bash

function hash() {
  printf "%s" "${1}" | md5sum | cut -d' ' -f1
}

function store::basepath() {
  mkdir -p "${1}"
  export STORE_PATH=${1}
}

function store::kv() {
  KV_NAME=${1}

  kv_path="${STORE_PATH}/${KV_NAME}"
  mkdir -p "${kv_path}"
  touch "${kv_path}/keys"

  export KV_NAME
}

function kv::set() {
  [[ $# -eq 3 ]] && store::kv "${1}" && shift

  kv_path="${STORE_PATH}/${KV_NAME}"
  key=${1}; value=${2};

  hash=$(hash "${key}")
  printf "%s" "${value}" > "${kv_path}/${hash}"

  grep -q "${key}" "${kv_path}/keys"
  if [[ $? -ne 0 ]]; then
    printf "%s\n" "${key}" >> "${kv_path}/keys"
  fi
}

function kv::get() {
  [[ $# -eq 2 ]] && store::kv "${1}" && shift

  kv_path="${STORE_PATH}/${KV_NAME}"
  key=${1}

  hash=$(hash "${key}")
  if [[ -f "${kv_path}/${hash}" ]]; then
    cat "${kv_path}/${hash}"
  fi
}

function kv::keys() {
  [[ $# -eq 1 ]] && store::kv "${1}" && shift

  kv_path="${STORE_PATH}/${KV_NAME}"

  if [[ -f "${kv_path}/keys" ]]; then
    cat "${kv_path}/keys"
  fi
}
