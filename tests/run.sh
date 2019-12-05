#!/usr/bin/env sh
#   Copyright 2019 Hedera Hashgraph LLC
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

####################
# Script constants #
####################


# Script version, which is a semantic versioning string.
SEMVER="0.1.0"

# Usage string roughly follows 'docopt' spec 0.6.
USAGE="$0: Run test commands.

Usage:
  $0 (<-h>|<--help>|<--version>)

Options:
  -h | --help  Output this message.
  --version    Output the version number.

Examples:
  $0 --help
  $0 --version
"

# Parameter types
PARAM_NOT_OPTION=0
PARAM_SHORT_OPTION=1
PARAM_LONG_OPTION=2


#############
# Functions #
#############


read_param_type() {
    PARAM="$1"
    LEN=`printf '%s' "$PARAM" | wc -c`
    if [ $LEN -ge 2 -a "`printf '%s' "$PARAM" | cut -c1-2`" = '--' ] ; then
        printf '%d' $PARAM_LONG_OPTION
    elif [ $LEN -eq 2 -a "`printf '%s' "$PARAM" | cut -c1`" = '-' ] ; then
        printf '%d' $PARAM_SHORT_OPTION
    else
        printf '%d' $PARAM_NOT_OPTION
    fi
}

########
# Body #
########


#
# Read parameters.
#

HELP=0
VERSION=0
while : ; do
    PARAM_TYPE=`read_param_type "$1"`
    case $PARAM_TYPE in
        $PARAM_SHORT_OPTION) {
            if [ "$1" = '-h' ] ; then
                HELP=1
            else
                printf '\nInvalid short option "%s".\n' "$1" >&2
                HELP=2
            fi
        };;
        $PARAM_LONG_OPTION) {
            if [ "$1" = '--help' ] ; then
                HELP=1
            elif [ "$1" = '--version' ] ; then
                VERSION=1
            else
                printf '\nInvalid long option "%s".\n' "$1" >&2
                HELP=2
            fi
        };;
        *) {
            break
        };;
    esac
    shift
done

# Read command.
COMMAND=""
if [ $# -gt 0 ] ; then
    COMMAND="$1"
    shift
else
    # Default command is currently '--help'.
    COMMAND='--help'
fi


#
# Perform commands.
#


perform_version() {
    printf "%s\n" "$SEMVER"
}

# Note that -h and --help are promoted to commands if provided as a script
# option, and override any other behavior.
if [ $HELP -eq 0 ] ; then
    # Version is promoted to a command overrides any other command.
    if [ $VERSION -ne 0 ] ; then
        COMMAND='version'
    fi
    case $COMMAND in
        '--help') {
            HELP=1
        };;
        'version') {
            perform_version
        };;
        *) {
            printf '\nInvalid command "%s".\n' "$COMMAND" >&2
            HELP=2
        };;
    esac
fi

case $HELP in
    1) {
        printf '%s\n' "$USAGE"
        exit 0
    };;
    0) {
        :
    };;
    2|*) {
        printf '\nPrinting usage.\n\n%s\n' "$USAGE" >&2
        exit 2
    };;
esac
