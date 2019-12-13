#!/usr/bin/env bash
set -o nounset
set -o pipefail
if [ `which ruby` = '/usr/local/opt/ruby/bin/ruby' ] ; then
    exit 0
fi
BREW_USER_RUBY_OUTPUT=`brew install ruby`
BREW_USER_RUBY_RESULT=$?
if [ $BREW_USER_RUBY_RESULT -ne 0 ] ; then
    printf 'Failed to brew user ruby with error %s.\n' \
        "$BREW_USER_RUBY_RESULT" \
        >&2
    exit $BREW_USER_RUBY_RESULT
fi
GEM_HOME=`printf '%s\n' "$BREW_USER_RUBY_OUTPUT" | \
    sed -n -E -e 's|[[:space:]]*/usr/local/lib/ruby/gems/([.[:digit:]]+)/bin[[:space:]]*|~/.gem/ruby/\1|p'`
GEM_RESULT=$?
if [ $GEM_RESULT -ne 0 ] ; then
    printf "Attempt to find brew's reported gems directory name failed.\n" >&2
    exit $GEM_RESULT
fi
if [ "$GEM_HOME" = "" ] ; then
    printf "Failed to find brew's reported gems directory name.\n" >&2
    exit 1
fi
if [ `printf '%s\n' $GEM_HOME | wc -l` -gt 1 ] ; then
    printf "Homebrew reported too many gems directory names.\n" >&2
    exit 1
fi
printf '%s\n%s\n%s\n' \
    "export RUBY_HOME=/usr/local/opt/ruby/bin" \
    "export GEM_HOME=$GEM_HOME" \
    "export PATH=\$GEM_HOME/bin:\$RUBY_HOME:\$PATH" \
    >> ~/.bash_profile
