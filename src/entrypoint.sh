#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

WEEWX_ROOT="/data"
CONF_FILE="${WEEWX_ROOT}/weewx.conf"

# echo version before starting syslog so we don't confound our tests
if [ $# -gt 0 ] && [ "$1" = "--version" ]; then
  gosu weewx:weewx weewxd --version
  exit 0
fi

if [ "$(id -u)" = 0 ]; then
  # set timezone using environment
  ln -snf /usr/share/zoneinfo/"${TIMEZONE:-UTC}" /etc/localtime
  # start the syslog daemon as root
  /sbin/syslogd -n -S -O - &
  if [ "${WEEWX_UID:-weewx}" != 0 ]; then
    # drop privileges and restart this script
    echo "Switching uid:gid to ${WEEWX_UID:-weewx}:${WEEWX_GID:-weewx}"
    gosu "${WEEWX_UID:-weewx}:${WEEWX_GID:-weewx}" "$(readlink -f "$0")" "$@"
    exit 0
  fi
fi

if [ ! -f "${CONF_FILE}" ]; then
  weectl station create --no-prompt ${WEEWX_ROOT}
  echo "A new set of configurations was created."
  echo "Please edit ${CONF_FILE} and restart the container."
fi

# if we have any parameters we'll send them to weectl

if [ $# -gt 0 ]; then
  weectl "$@" --config ${CONF_FILE}
  exit 0
else
  weewxd --config ${CONF_FILE}
fi
