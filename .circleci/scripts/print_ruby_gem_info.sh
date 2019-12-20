#!/usr/bin/env bash
set -o nounset
set -o errexit
set -o pipefail

printf 'Ruby at: %s\n' `which ruby`
ruby --version
printf 'Gem at: %s\n' `which gem`
gem --version
gem list --local
