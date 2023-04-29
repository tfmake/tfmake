#!/usr/bin/env bash

TFMAKE_DATA_DIR="${TFMAKE_DATA_DIR:-".tfmake"}"

# shellcheck disable=SC2034,SC2155
{
  TAB=$(printf '\t')
  BACKTICKS='```'
}

function util::log_err() {
  echo "${1}" >&2
  exit 1
}

function util::splitlines() {
  echo "${1}" | tr '\r\n' ' ' | xargs
}

function util::append_new_line() {
  printf "\n" >> "${1}"
}

function util::file_exist_condition () {
  file=${1}; command=${2};

  if [[ ! -f ${file} ]]; then
    util::log_err ">>> Run '${command}' first."
  fi
}

function util::validate_context() {
  if [[ -z "${1-}" ]]; then
    util::log_err ">>> Run 'tfmake context <plan|apply>' first."
  fi

  if [[ ! "${1-}" =~ ^(plan|apply)$ ]]; then
    printf ">>> Invalid context: %s.\n" "${1-}"
    exit 1
  fi
}
