#!/usr/bin/env bash

function hash() {
  local key="${1-}"

  printf "%s" "${key}" | md5sum | cut -d' ' -f1
}

function store::basepath() {
  local path="${1-}"

  mkdir -p "${path}"
  export STORE_PATH=${path}
}

function store::use() {
  local path="${1-}"

  KV_PATH="${STORE_PATH}/${path}"

  mkdir -p "${KV_PATH}"
  touch "${KV_PATH}/keys"

  export KV_PATH
}

function store::truncate() {
  local path="${1-}"

  KV_PATH="${STORE_PATH}/${path}"

  if [[ -d "${KV_PATH}" ]]; then
    find "${KV_PATH}" -type f -delete
  fi

  store::use "${path}"
}

function kv::set() {
  local key="${1-}"
  local value="${2-}"

  hash=$(hash "${key}")
  printf "%s" "${value}" > "${KV_PATH}/${hash}"

  grep -q "${key}" "${KV_PATH}/keys"
  if [[ $? -ne 0 ]]; then
    printf "%s\n" "${key}" >> "${KV_PATH}/keys"
  fi
}

function kv::get() {
  local key="${1-}"

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
