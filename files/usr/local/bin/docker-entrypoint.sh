#!/bin/bash

set -o xtrace

# Running Confluence in foreground
exec /etc/init.d/confluence start -fg
