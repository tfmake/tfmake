#!/usr/bin/env bash

TFMAKE_DATA_DIR="${TFMAKE_DATA_DIR:-".tfmake"}"

# shellcheck disable=SC2034,SC2155
{
  TAB=$(printf '\t')
  BACKTICKS='```'
}

function util::log_info() {
  local msg="${1-}"
  echo >&2 -e "[$(date -u)] [INFO] ${msg}"
}

function util::log_err() {
  local msg="${1-}"
  echo >&2 -e "[$(date -u)] [ERROR] ${msg}"

  exit 1
}

function util::msg() {
  local msg="${1-}"
  echo >&2 -e "${msg}"
}

function util::die() {
  local msg="${1-}"
  echo >&2 -e "${msg}"

  exit 1
}

function util::splitlines() {
  local lines="${1-}"

  echo "${lines}" | xargs
}

function util::append_new_line() {
  local file="${1-}"

  printf "\n" >> "${file}"
}

function util::file_exist_condition () {
  local file="${1-}"
  local command="${2-}"

  if [[ ! -f ${file} ]]; then
    util::die "Run '${command}' first."
  fi
}

function util::context() {
  TFMAKE_CONTEXT=$(util::global_config_get "context")

  if [[ -z "${TFMAKE_CONTEXT}" ]]; then
    util::die "Run 'tfmake context <plan|apply|destroy>' first."
  fi

  if [[ ! "${TFMAKE_CONTEXT}" =~ ^(plan|apply|destroy)$ ]]; then
    util::die "Invalid context: ${TFMAKE_CONTEXT}"
  fi
}

function util::global_config_set() {
  local key="${1-}"
  local value="${2-}"

  # validation
  if [[ -z "${key}" ]]; then
    util::die "Missing config key."
  fi

  if [[ -z "${value}" ]]; then
    util::die "Missing config value for '${key}' key."
  fi

  store::basepath "${TFMAKE_DATA_DIR}/global/store"
  store::use config

  kv::set "${key}" "${value}"
}

function util::global_config_get() {
  local key="${1-}"

  # validation
  if [[ -z "${key}" ]]; then
    util::die "Missing config key."
  fi

  store::basepath "${TFMAKE_DATA_DIR}/global/store"
  store::use config

  kv::get "${key}"
}
