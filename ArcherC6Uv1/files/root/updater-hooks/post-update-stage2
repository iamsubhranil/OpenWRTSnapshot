#!/bin/sh

LOGGER_PROMPT="Orbiter"

set -e
set -o pipefail

log "Setup completed successfully!"

log "Pushing upgrade logs.."
chmod +x $BASEDIR/push_logs.sh
$BASEDIR/push_logs.sh
