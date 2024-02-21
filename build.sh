#! /usr/bin/env bash
set -Eeuo pipefail

lollms_commit=$(git rev-parse --short --verify HEAD:./lollms-webui)

printf 'LOLLMS_COMMIT="%s"\n' "${lollms_commit}" > .env.hcl

docker buildx bake -f docker-bake.hcl -f .env.hcl "$@"
