#!/usr/bin/env bash

DATA_DIR="${DATA_DIR:-".tfmake"}"

# shellcheck disable=SC2034,SC2155
{
  TAB=$(printf '\t')
  BACKTICKS='```'
}

function log::err() {
  echo "${1}" >&2
  exit 1
}

function utils::splitlines() {
  echo "${1}" | tr '\r\n' ' ' | xargs
}

function file::new_line() {
  printf "\n" >> "${1}"
}

function file::exist_condition () {
  file=${1}; command=${2};

  if [[ ! -f ${file} ]]; then
    log::err ">>> Run '${command}' first."
  fi
}
