#! /usr/bin/env bash
set -Eeuo pipefail

if ! command -v realpath &> /dev/null; then
  export alias realpath="readlink -f"
fi

# shellcheck disable=SC2128
# shellcheck disable=SC2030
script_source=$([[ -z "$BASH_SOURCE" ]] && echo "$0" || echo "$BASH_SOURCE")
script_file=$(realpath "${script_source}")
script_dir=$(dirname -- "${script_file}")
root_dir=$(dirname -- "${script_dir}")

cd "${root_dir}"

lollms_commit=$(git rev-parse --short --verify HEAD:./lollms-webui)

printf 'LOLLMS_COMMIT="%s"\n' "${lollms_commit}"
