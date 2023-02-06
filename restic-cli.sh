#!/bin/bash
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${BASE_DIR}/restic-lib.sh

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

