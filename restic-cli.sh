#!/bin/bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RESTIC_PASSWORD_FILE="${BASE_DIR}/restic-password.secret"
B2_AUTH_FILE="${BASE_DIR}/b2-auth.secret"

# Source configs and keys
source ${B2_AUTH_FILE}
source ${BASE_DIR}/defaults.config
[ -f ${BASE_DIR}/config ] && source ${BASE_DIR}/config

# Catch errors
[ ! -f ${RESTIC_PASSWORD_FILE} ] && echo "ERROR: No restic password present" && exit 1
[ ! -f ${B2_AUTH_FILE} ] && echo "ERROR: No b2 auth present" && exit 1
if ! which restic &>/dev/null; then echo "ERROR: restic not found" && exit 1; fi

EXTRA_SWITCHES=""
[ ! -z "$B2_CONNECTIONS" ] && EXTRA_SWITCHES="-o b2.connections=${B2_CONNECTIONS} "

# If bucket is defined shift the behaviour a bit
if [ $1 == "--bucket" ]; then
	shift
	BUCKET="$1"
  HOSTNAME="/"
	shift
else
 BUCKET="$B2_BUCKET"
fi

restic -p ${RESTIC_PASSWORD_FILE} ${EXTRA_SWITCHES} -r b2:${BUCKET}:${HOSTNAME} $@

