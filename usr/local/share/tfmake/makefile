#!/usr/bin/env bash

set -u

# shellcheck source=/dev/null
{
  source "${TFMAKE_SCRIPT_DIR}/../include/tfmake/util.sh"
  source "${TFMAKE_SCRIPT_DIR}/../include/tfmake/store.sh"
}

function usage() {
  cat << EOF
Usage:
  tfmake makefile [options]

  This command generate a Makefile for Terraform plan/apply execution.

Options:
  -h, --help, help  Show this help output.
EOF
  exit
}

case "${1-}" in
  -h|--help|help)
    usage
    ;;
  ?*)
    printf ">>> Unknown option: %s\n\n" "${1}"
    usage
    ;;
esac

SCRIPT_PATH="${TFMAKE_SCRIPT_DIR}/../share/tfmake/makefile-${TFMAKE_CONTEXT}"
exec "bash" "${SCRIPT_PATH}" "$@"
