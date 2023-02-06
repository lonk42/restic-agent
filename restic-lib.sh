#!/bin/bash
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source config
source ${BASE_DIR}/defaults.config
[ -f ${BASE_DIR}/config ] && source ${BASE_DIR}/config

# Catch errors
[ ! -f ${RESTIC_PASSWORD_FILE} ] && echo "ERROR: No restic password present" && exit 1
if ! which restic &>/dev/null; then echo "ERROR: restic not found" && exit 1; fi

function log {
  DATESTRING=$(date -u '+%F %X')
  echo -e "$DATESTRING | $1"
}


