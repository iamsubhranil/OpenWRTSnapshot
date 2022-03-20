#!/bin/sh

LOGGER_PROMPT="Orbiter"
. /root/updater/logger.sh

set -e
set -o pipefail

log "Removing setup scripts.."
rm -rf /root/setup
rm -rf /rwm/upper/root/setup

log "Disabling final stage.."
/etc/init.d/z_setup_final_stage disable
rm -f /etc/init.d/z_setup_final_stage

log "Setup completed successfully!"

log "Pushing upgrade logs.."
chmod +x /root/updater/push_logs.sh
/root/updater/push_logs.sh
