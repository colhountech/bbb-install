#!/bin/bash
# Deploy apply-config.sh to the BBB server and re-apply settings.
set -euo pipefail

BBB_HOST="${BBB_HOST:-root@78.47.120.165}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Deploying apply-config.sh, index.html, and bbb-custom.css to ${BBB_HOST}…"
scp "${SCRIPT_DIR}/apply-config.sh" "${BBB_HOST}:/etc/bigbluebutton/bbb-conf/apply-config.sh"
scp "${SCRIPT_DIR}/index.html" "${BBB_HOST}:/etc/bigbluebutton/bbb-conf/index.html"
scp "${SCRIPT_DIR}/bbb-custom.css" "${BBB_HOST}:/etc/bigbluebutton/bbb-conf/bbb-custom.css"
ssh "${BBB_HOST}" "chmod +x /etc/bigbluebutton/bbb-conf/apply-config.sh && bash /etc/bigbluebutton/bbb-conf/apply-config.sh"
echo "Done. Run 'ssh ${BBB_HOST} bbb-conf --restart' if html5 client changes need a full restart."