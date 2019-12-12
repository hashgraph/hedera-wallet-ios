#!/usr/bin/env bash
set -o nounset
set -o errexit
BREW_VERSION=`brew --version`
printf 'Brew version: %s\n\n' "$BREW_VERSION"
printf 'Requested brews:\n'
brew leaves
brew cask list
printf '\nAll installed brews:\n'
brew list -1
# Available by 2.1.15:
# brew list --verbose
brew cask list
printf '\n'
