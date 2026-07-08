#!/bin/bash
# Deploy apply-config.sh to the BBB server and re-apply settings.
set -euo pipefail

BBB_HOST="${BBB_HOST:-root@78.47.120.165}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Deploying apply-config.sh to ${BBB_HOST}…"
scp "${SCRIPT_DIR}/apply-config.sh" "${BBB_HOST}:/etc/bigbluebutton/bbb-conf/apply-config.sh"
ssh "${BBB_HOST}" "chmod +x /etc/bigbluebutton/bbb-conf/apply-config.sh && bash /etc/bigbluebutton/bbb-conf/apply-config.sh"
echo "Done. Run 'ssh ${BBB_HOST} bbb-conf --restart' if html5 client changes need a full restart."