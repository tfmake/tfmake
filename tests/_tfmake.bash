#!/usr/bin/env bash

IAC_TOOL=${IAC_TOOL:-"terraform"}

# shellcheck source=/dev/null
{
  source "${BATS_TESTS_DIR}/../usr/local/include/tfmake/util.sh"
  source "${BATS_TESTS_DIR}/../usr/local/include/tfmake/store.sh"
}

TF_MODULES_PATH="${BATS_TESTS_DIR}/terraform/basic"

function cd_terraform_modules_path() {
  cd "${TF_MODULES_PATH}" || exit

  mkdir -p B/.terraform/modules/D
  if [[ ! -f B/.terraform/modules/D/main.tf ]]; then
    touch B/.terraform/modules/D/main.tf
  fi

  tfmake config --set iactool "${IAC_TOOL}"
}

function add_invalid_module() {
  cd "${TF_MODULES_PATH}" || exit

  mkdir -p "${1-}"
  if [[ ! -f E/main.tf ]]; then
    cat << EOF > "${1-}/main.tf"
resource "random_id" "id" {
  keepers = {
    // var content is missing, therefore MUST fail
    content = var.content
  }

  byte_length = 8
}

output "id" {
  value = random_id.id.id
}
EOF
  fi
}

function remove_invalid_module() {
  cd "${TF_MODULES_PATH}" || exit
  rm -rf "${1-}"
}
