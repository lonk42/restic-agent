#!/bin/bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RESTIC_MASTER_PASSWORD_FILE="${BASE_DIR}/restic-master-password.secret"
B2_AUTH_FILE="${BASE_DIR}/b2-auth.secret"

# Source configs and keys
source ${B2_AUTH_FILE}
source ${BASE_DIR}/defaults.config
[ -f ${BASE_DIR}/config ] && source ${BASE_DIR}/config

# Catch errors
[ ! -f ${RESTIC_MASTER_PASSWORD_FILE} ] && echo "ERROR: No restic password present" && exit 1
[ ! -f ${B2_AUTH_FILE} ] && echo "ERROR: No b2 auth present" && exit 1
if ! which restic &>/dev/null; then echo "ERROR: restic not found" && exit 1; fi
if ! which b2 &>/dev/null; then echo "ERROR: restic not found" && exit 1; fi

restic -p ${RESTIC_MASTER_PASSWORD_FILE} -r b2:${B2_BUCKET}:${@}

