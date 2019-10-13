#!/bin/bash

set -o xtrace

# Prepend executable if command starts with an option
if [ "${1:0:1}" = '-' ]; then
    set -- /opt/atlassian/confluence/bin/start-confluence.sh "$@"
fi

# Allow the container to be stated with `--user`
if [ "$1" = '/opt/atlassian/confluence/bin/start-confluence.sh' ] && [ "$(id -u)" = '0' ]; then
    mkdir -p $CONFLUENCE_HOME
    chown $CONFLUENCE_OWNER:$CONFLUENCE_GROUP $CONFLUENCE_HOME
    chmod 0755 $CONFLUENCE_HOME
    exec gosu $CONFLUENCE_OWNER "$BASH_SOURCE" "$@"
fi

exec "$@"
