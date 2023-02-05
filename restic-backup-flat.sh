#!/bin/bash

echo "This script is depricated, to use this functionality it must be updated to meet new config options"
exit 1

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

function log {
  DATESTRING=$(date -u '+%F %X')
  echo -e "$DATESTRING | $1"
}

# Check we have anything to do
[ -z "${BACK_FLAT_DIRECTORIES}" ] && log "No flat backups configured"

while read FLAT_MAPPING; do

	BACKUP_DIRECTORY="$(echo "$FLAT_MAPPING" | awk '{print$1}')"
	BACKUP_ALIAS="$(echo "$FLAT_MAPPING" | awk '{print$2}')"

	# Start backup
	log "Beginning restic run for ${HOSTNAME} | ${BACKUP_ALIAS} (${BACKUP_DIRECTORY})"

	# Initalize a new restic repository if there isn't one already
	if ! restic --cache-dir /tmp/restic -p ${RESTIC_PASSWORD_FILE} -r b2:${BACKUP_ALIAS}:/ list index &>/dev/null
	then
		log "Initalizing new restic respository for ${HOSTNAME} | ${BACKUP_ALIAS} (${BACKUP_DIRECTORY})"
		restic --cache-dir /tmp/restic -p ${RESTIC_PASSWORD_FILE} -r b2:${BACKUP_ALIAS}:/ init
	fi

	# Run the restic backup for the container
	log "Backing up ${HOSTNAME} | ${BACKUP_ALIAS} (${BACKUP_DIRECTORY})"
	restic --cache-dir /tmp/restic -p ${RESTIC_PASSWORD_FILE} -o b2.connections=20 -r b2:${BACKUP_ALIAS}:/ backup ${BACKUP_DIRECTORY}

	# Retain snapshots to configured level
	log "Rotating snapshots for ${HOSTNAME} | ${BACKUP_ALIAS} (${BACKUP_DIRECTORY})"
  restic --cache-dir /tmp/restic -p ${RESTIC_PASSWORD_FILE} -o b2.connections=20 -r b2:${BACKUP_ALIAS}:/  forget --keep-last 14 --prune

	log "Restic backup finished for ${HOSTNAME} | ${BACKUP_ALIAS} (${BACKUP_DIRECTORY})"

done < <(echo "${BACKUP_FLAT_DIRECTORIES}")
