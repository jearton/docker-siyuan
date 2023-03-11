#!/usr/bin/env bash
set -e

WORKING_DIR=/opt/siyuan
REFRESH_SCRIPT_FILE=refresh-siyuan.sh

_err() {
  # print error text with red color
  echo -e "\033[31m $1 \033[0m" >&2
}

installcronjob() {
  cronExpr=$1

  if [ -f "$WORKING_DIR/$REFRESH_SCRIPT_FILE" ]; then
    # default: "/opt/siyuan"/refresh-siyuan.sh
    execsh="\"$WORKING_DIR\"/$REFRESH_SCRIPT_FILE"
  else
    _err "Can not install cronjob, $WORKING_DIR/$REFRESH_SCRIPT_FILE not exists."
    return 1
  fi

  if [ -z "$cronExpr" ]; then
    _err "Cron expression must not be empty."
    return 1
  fi

  echo "Installing cron job"
  if ! crontab -l | grep "$REFRESH_SCRIPT_FILE"; then
    # For example：1-59/15 * * * * "/opt/siyuan"/refresh-siyuan.sh
    echo "$cronExpr $execsh" | crontab
    crontab -l
  fi
}

uninstallcronjob() {
  echo "Uninstalling cron job"
  crontab -r
}

if [ "$REFRESH_CRON_JOB" = 'on' ]; then
  installcronjob "$REFRESH_CRON_EXPR"
  /etc/init.d/cron start
  /etc/init.d/cron status
else
  uninstallcronjob
fi

echo "Starting siyuan kernel"
/opt/siyuan/kernel "$@"
