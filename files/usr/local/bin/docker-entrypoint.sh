#!/bin/bash

set -o xtrace

# Prepend executable if command starts with an option
if [ "${1:0:1}" = '-' ]; then
    set -- /opt/atlassian/confluence/bin/start-confluence.sh "$@"
fi

# Ensure required folders exist with correct owner:group
mkdir -p $CONFLUENCE_HOME
chown -Rf $CONFLUENCE_OWNER:$CONFLUENCE_GROUP $CONFLUENCE_HOME
chmod 0755 $CONFLUENCE_HOME

exec "$@"
