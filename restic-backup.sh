#!/bin/bash
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${BASE_DIR}/restic-lib.sh

# Grab the prune switch if it was given
PRUNE_SWITCH=""
if [ "${1}x" == "--prunex" ]; then
	log "Prune is enabled."
	PRUNE_SWITCH="--prune"
fi

# Define any overrides
EXTRA_SWITCHES=""
[ ! -z "$RESTIC_CACHE_DIRECTORY" ] && EXTRA_SWITCHES+="--cache-dir ${RESTIC_CACHE_DIRECTORY} " && mkdir -p "${RESTIC_CACHE_DIRECTORY}"
[ ! -z "$B2_CONNECTIONS" ] && EXTRA_SWITCHES+="-o b2.connections=${B2_CONNECTIONS} "

# Start backup
log "Beginning restic run for ${HOSTNAME}"

# Initalize a new restic repository if there isn't one already
if ! restic -p ${RESTIC_PASSWORD_FILE} -r b2:${B2_BUCKET}:${HOSTNAME} list index &>/dev/null; then
	log "Initalizing new restic respository for ${HOSTNAME}"
	restic -p ${RESTIC_PASSWORD_FILE} -r b2:${B2_BUCKET}:${HOSTNAME} init
fi

# Run the restic backup for the container
log "Backing up ${HOSTNAME}"
restic -p ${RESTIC_PASSWORD_FILE} ${EXTRA_SWITCHES} -r b2:${B2_BUCKET}:${HOSTNAME} backup ${CUSTOM_EXCLUDES} ${DEFAULT_EXCLUDES} / 

# Retain snapshots to configured level
log "Rotating snapshots for ${HOSTNAME}"

if [ ! -z "$RETENTION_STRING" ]; then
	log "Using date based retention for ${HOSTNAME}, string '${RETENTION_STRING}'"
	restic -p ${RESTIC_PASSWORD_FILE} ${EXTRA_SWITCHES} -r b2:${B2_BUCKET}:${HOSTNAME} forget ${RETENTION_STRING} ${PRUNE_SWITCH}
else
	log "Using legacy n retention for ${HOSTNAME}, ${RETENTION} days retention"
	restic -p ${RESTIC_PASSWORD_FILE} ${EXTRA_SWITCHES} -r b2:${B2_BUCKET}:${HOSTNAME} forget --keep-last ${RETENTION_AMOUNT} ${PRUNE_SWITCH}
fi

log "Restic backup finished for ${HOSTNAME}"
