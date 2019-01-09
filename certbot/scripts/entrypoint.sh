#!/bin/sh
log_lvl_info() {
  NOW=$(date +"%Y/%m/%d %H:%M:%S")
  if [ -n "${LOGFILE}" ]; then
    echo "${NOW} [info] ${1}" >> ${LOGFILE}
  else
    echo "${NOW} [info] ${1}" > /proc/1/fd/1 2>/proc/1/fd/2
  fi
}

log_lvl_info "Waiting for $HEALTH_CHECK_URL..."

if [ -z $HEALTH_CHECK_URL ]; then
    log_lvl_info "No HEALTH_CHECK_URL configured. Starting certbot without healthcheck"
else
    # Wait for provided $HEALTH_CHECK_URL to become online
    until [ $(curl -s -L --head --fail -o /dev/null -w '%{http_code}\n' --connect-timeout 3 --max-time 5 $HEALTH_CHECK_URL) -eq 200 ]; do
      printf '.'
      sleep 5
    done
log_lvl_info "$HEALTH_CHECK_URL is online."
fi

/scripts/certbot.sh
# scheduling periodic executions
exec crond -f
