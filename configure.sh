#!/usr/bin/env bash
set -o nounset
DOTS='........................................................................'

print_error_followup() {
    printf '\nYour configuration is incomplete.  Please contact '
    printf '%s on our\n' "'Robert Strickland#4049'"
    printf 'Discord server, %s, with a copy of this ' "'Hedera Hashgraph'"
    printf 'program output.\n\n'
}

printf '\nConfiguring the Hedera iOS wallet project for the first time.\n'
printf '\nPlease note that this script may not work on all machines.\n'

printf '%.71s ' "Checking the current working directory$DOTS"
if [ ! -d .circleci/scripts ] ; then
    printf 'FAILED.\n'
    printf '\nExecute this script from the root directory of the ' >&2
    printf 'hedera-wallet-ios directory (the\nlocation of this script) ' >&2
    printf 'or it will not run properly.\n' >&2
    print_error_followup
    exit 1
fi
printf 'PASSED.\n'

# WIP
printf '%.71s FAILED.\n' "Checking that the script is fully written$DOTS"
print_error_followup
exit 3
