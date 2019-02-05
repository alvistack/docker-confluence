#!/bin/bash

set -o xtrace

# Ensure required folders exist with correct owner:group
mkdir -p $CONFLUENCE_HOME
chmod 0755 $CONFLUENCE_HOME
chown -Rf $CONFLUENCE_OWNER:$CONFLUENCE_GROUP $CONFLUENCE_HOME

# Running Confluence in foreground
exec /etc/init.d/confluence start -fg
