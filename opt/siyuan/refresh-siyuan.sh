#!/usr/bin/env bash
# Example：1-59/15 * * * * "/opt/siyuan"/refresh-siyuan.sh
LOG_DIR=/siyuan/logs
LOG_FILE="$LOG_DIR/refresh-file-tree.log"
REFRESH_URL="http://127.0.0.1:6806/api/filetree/refreshFiletree"

if [ ! -d "$LOG_DIR" ]; then
  mkdir -p "${LOG_DIR}"
fi

{
  date
  echo "Refresh notes..."
  curl -s -X POST "$REFRESH_URL" 2>&1 | {
    cat -
    echo ""
  }
  echo "Refresh finished!"
  date
} >"$LOG_FILE"
