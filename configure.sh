#!/usr/bin/env bash
set -o nounset
DOTS='........................................................................'
SCRIPTS_DIR='.circleci/scripts'
PRINT_HOMEBREW_SCRIPT="$SCRIPTS_DIR/print_homebrew_info.sh"

# Help support
while [ $# -ne 0 ] ; do
    if [ "$1" = '-h' -o "$1" = '--help' -o "$1" = 'help' ] ; then
        printf '%s\n' "$0 - configure the environment for building the wallet"
        printf '\nUsage:\n'
        printf '    configure.sh\n'
        printf '\nPlease note that this script may not work on all machines.\n'
        printf '\n'
        exit 0
    fi
done

print_error_followup() {
    printf '\nYour configuration is incomplete.  Please contact '
    printf '%s on our\n' "'Robert Strickland#4049'"
    printf 'Discord server, %s, with a copy of this ' "'Hedera Hashgraph'"
    printf 'program output.\n\n'
}

printf '\nConfiguring the Hedera iOS wallet project for the first time.\n'
printf '\nPlease note that this script may not work on all machines.\n'

printf '%.71s ' "Checking the current working directory$DOTS"
if [ ! -d "$SCRIPTS_DIR" ] ; then
    printf 'FAILED.\n'
    printf '\nExecute this script from the root directory of the ' >&2
    printf 'hedera-wallet-ios directory (the\nlocation of this script) ' >&2
    printf 'or it will not run properly.\n' >&2
    print_error_followup
    exit 1
fi
printf 'PASSED.\n'

printf '%.71s ' "Checking for XCode command line tools$DOTS"
XCODE_OUTPUT=`xcrun --find xcodebuild 2>&1`
XCODE_PRESENT=$?
if [ $XCODE_PRESENT -eq 0 ] ; then
    printf 'PRESENT.\n'
else
    printf 'MISSING.\n'
    printf '%s' "$XCODE_OUTPUT"
fi

printf '%.71s ' "Checking for Homebrew$DOTS"
BREW_OUTPUT=`which brew`
BREW_PRESENT=$?
if [ $BREW_PRESENT -eq 0 ] ; then
    printf 'PRESENT.\n'
else
    printf 'MISSING.\n'
fi

# WIP: check for (user) Ruby and gem to be installed
printf '%.71s ' "Checking for (user-installed) Ruby and gem$DOTS"
RUBY_OUTPUT=`which ruby`
RUBY_FOUND=$?
EXPECTED_RUBY_RESOLUTION='/usr/local/opt/ruby/bin/ruby'
if [ $RUBY_FOUND -eq 0 -a "$RUBY_OUTPUT" = "$EXPECTED_RUBY_RESOLUTION" ] ; then
    printf 'PRESENT.\n'
    RUBY_PRESENT=1
elif [ $RUBY_FOUND -eq 0 ] ; then
    printf 'SYSTEM.\n'
    RUBY_PRESENT=0
else
    printf 'MISSING.\n'
    RUBY_PRESENT=0
fi

# WIP: check for Cocoapods

# WIP: check for protobuf, swift-protobuf, grpc-swift

# WIP: check for scripts

if [ ! -e "$PRINT_HOMEBREW_SCRIPT" ] ; then
    printf '\nUnable to continue, %s missing.\n' "'$PRINT_HOMEBREW_SCRIPT'"
    print_error_followup
    exit 1
fi

# WIP
printf '%.71s FAILED.\n' "Checking that the script is fully written$DOTS"
print_error_followup
exit 3
