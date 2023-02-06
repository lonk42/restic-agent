#!/bin/bash
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${BASE_DIR}/restic-lib.sh

RESTIC_MASTER_PASSWORD_FILE="${BASE_DIR}/restic-master-password.secret"

# Catch errors
[ ! -f ${RESTIC_MASTER_PASSWORD_FILE} ] && echo "ERROR: No restic password present" && exit 1
#if ! which b2 &>/dev/null; then echo "ERROR: restic not found" && exit 1; fi

restic -p ${RESTIC_MASTER_PASSWORD_FILE} -r b2:${B2_BUCKET}:${@}

