#!/usr/bin/env bash

TFMAKE_DATA_DIR="${TFMAKE_DATA_DIR:-".tfmake"}"

# shellcheck disable=SC2034,SC2155
{
  TAB=$(printf '\t')
  BACKTICKS='```'
}

function util::log_err() {
  local msg="${1-}"

  echo "${msg}" >&2
  exit 1
}

function util::splitlines() {
  local lines="${1-}"

  echo "${lines}" | tr '\r\n' ' ' | xargs
}

function util::append_new_line() {
  local file="${1-}"

  printf "\n" >> "${file}"
}

function util::file_exist_condition () {
  local file="${1-}"
  local command="${2-}"

  if [[ ! -f ${file} ]]; then
    util::log_err ">>> Run '${command}' first."
  fi
}

function util::validate_context() {
  local context="${1-}"

  if [[ -z "${context}" ]]; then
    util::log_err ">>> Run 'tfmake context <plan|apply>' first."
  fi

  if [[ ! "${context}" =~ ^(plan|apply)$ ]]; then
    util::log_err ">>> Invalid context: ${context}"
  fi
}

function util::global_config_set() {
  local key="${1-}"
  local value="${2-}"

  # validation
  if [[ -z "${key}" ]]; then
    util::log_err ">>> Missing config key."
  fi

  if [[ -z "${value}" ]]; then
    util::log_err ">>> Missing config value for '${key}' key."
  fi

  store::basepath "${TFMAKE_DATA_DIR}/global/store"
  store::use config

  kv::set "${key}" "${value}"
  printf "%s=%s\n" "${key}" "${value}"
}

function util::global_config_get() {
  local key="${1-}"

  # validation
  if [[ -z "${key}" ]]; then
    util::log_err ">>> Missing config key."
  fi

  store::basepath "${TFMAKE_DATA_DIR}/global/store"
  store::use config

  kv::get "${key}"
}
