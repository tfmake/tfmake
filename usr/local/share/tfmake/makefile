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
    printf "Unknown option: %s\n\n" "${1}"
    usage
    ;;
esac

# validations
util::file_exist_condition \
  "${TFMAKE_DATA_DIR}/${TFMAKE_CONTEXT}/store/modules/keys" \
  "tfmake init"

# subcommand
readonly TFMAKE_LOG_GROUPING="${TFMAKE_LOG_GROUPING:-"true"}"

# detect CI/CD platform
TFMAKE_CICD_PLATFORM="local"

if [[ "${GITHUB_ACTIONS:-}" == "true" && "${TFMAKE_LOG_GROUPING}" == "true" ]]; then
  TFMAKE_CICD_PLATFORM="github"
fi

util::global_config_set "cicd" "${TFMAKE_CICD_PLATFORM}"

# add canned recipes
cp \
  "${TFMAKE_SCRIPT_DIR}/../include/tfmake/recipes/${TFMAKE_CICD_PLATFORM}/grouping.mk" \
  "${TFMAKE_DATA_DIR}/${TFMAKE_CONTEXT}/recipes/grouping.mk"

# generate Makefile

util::log_info "[tfmake:makefile] generating Makefile for 'terraform ${TFMAKE_CONTEXT}' execution."

SCRIPT_PATH="${TFMAKE_SCRIPT_DIR}/../share/tfmake/makefile-${TFMAKE_CONTEXT}"
exec "bash" "${SCRIPT_PATH}" "$@"
