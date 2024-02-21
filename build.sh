#! /usr/bin/env bash
set -Eeuo pipefail

./scripts/build-env.sh > .env.hcl

docker buildx bake -f docker-bake.hcl -f .env.hcl "$@"
