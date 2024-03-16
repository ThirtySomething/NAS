#!/usr/bin/bash
#+------------------------------------------------------------------------------+
#| Script to backup docker volumes                                              |
#| Inspired by:                                                                 |
#| https://www.docker.com/blog/back-up-and-share-docker-volumes-with-this-extension/ |
#+------------------------------------------------------------------------------+
# Comment line out for debugging purposes
# set -x

#+------------------------------------------------------------------------------+
#| Variable definitions - Tweak here                                            |
#+------------------------------------------------------------------------------+
# Maximum number backups to keep
INT_KEEP=5

#+------------------------------------------------------------------------------+
#| Variable definitions - Don't touch                                           |
#+------------------------------------------------------------------------------+
# Get current name of backup folder
DIR_BACKUP=$(dirname "${0}")
DIR_BACKUP=$(realpath "${DIR_BACKUP}")
if [ -n "$1" ]
then
    DIR_BACKUP=${1}
fi

# current date
STR_DATE=$(date +%Y-%m-%d)
# File extensions
STR_EXT_ARCHIVE=tar.gz

#+------------------------------------------------------------------------------+
#| Convert duration of seconds to timestamp                                     |
#+------------------------------------------------------------------------------+
function get_duration {
    echo "$(date -d@${1} -u +%H:%M:%S)"
}

#+------------------------------------------------------------------------------+
#| Create name for the backup file                                              |
#+------------------------------------------------------------------------------+
function get_backup_name {
    # Build name of backup in form of volume-2023-11-01.tar.gz
    echo "${1}-${3}.${2}"
}

#+------------------------------------------------------------------------------+
#| Get container name                                                           |
#+------------------------------------------------------------------------------+
function get_container_name {
    # Strip container name from volume name
    echo "$(echo ${1} | cut -d '_' -f 1)"
}

#+------------------------------------------------------------------------------+
#| Create backup                                                                |
#+------------------------------------------------------------------------------+
function create_backup {
    # Internal variables
    TME_START=$(date +%s)
    VOLUME_NAME=${1}
    VAR_DST_NAME=$(get_backup_name "${1}" "${2}" "${3}")
    CUR_CONTAINER=$(get_container_name ${1})
    BACKUP_PATH="${DIR_BACKUP}/${CUR_CONTAINER}"
    BACKUP_FILE="${BACKUP_PATH}/${VAR_DST_NAME}"
    # Ensure directory for container
    mkdir -p "${BACKUP_PATH}"
    # Remove potential existing backups
    rm -f "${BACKUP_FILE}"
    # Perform backup
    docker run --rm \
    -v "${VOLUME_NAME}":/source \
    -v "${BACKUP_PATH}":/destination \
    busybox \
    tar -zcf /destination/${VAR_DST_NAME} /source
    TME_END=$(date +%s)
    DURATION=$(get_duration $(($TME_END-$TME_START)))
    echo "Backup of [${VOLUME_NAME}] done in ${DURATION}"
}

#+------------------------------------------------------------------------------+
#| Delete backups older than specified age                                      |
#+------------------------------------------------------------------------------+
function drop_old_backups {
    TME_START=$(date +%s)
    PATTERN_RAW=$(get_backup_name "${1}" "${2}" "*")
    CUR_CONTAINER=$(get_container_name "${1}")
    BACKUP_PATH="${DIR_BACKUP}/${CUR_CONTAINER}"
    PATTERN="${BACKUP_PATH}/${PATTERN_RAW}"
    FTK=$((10#1 + 10#${3}))
    # The solution for keep the last x files is described here
    # https://stackoverflow.com/questions/25785/delete-all-but-the-most-recent-x-files-in-bash
    # echo "$(date +'%Y%m%d-%H:%M:%S'): Keep the last ${3} backups"
    # echo "ls ${PATTERN} -tp | grep -v '/$' | tail -n +${FTK}"
    ls ${PATTERN} -tp | grep -v '/$' | tail -n "+${FTK}"
    ls ${PATTERN} -tp | grep -v '/$' | tail -n "+${FTK}" | xargs -I {} rm -- {}
    TME_END=$(date +%s)
    DURATION=$(get_duration $(($TME_END-$TME_START)))
    echo "Drop of old backups of [${PATTERN_RAW}] in ${DURATION}"
    echo ""
}

#+------------------------------------------------------------------------------+
#| Start not running container                                                  |
#+------------------------------------------------------------------------------+
function start_not_running_container {
    STP_CONTAINER=$(docker ps --format '{{.Names}}' --filter "status=exited" | wc -l)
    if [ "${STP_CONTAINER}" -gt "0" ]
    then
        echo "================================================================================"
        echo "***** Starting not running docker container(s) at $(date +'%d.%m.%Y-%H:%M:%S')"
        echo ""
        # List existing docker containers names only
        # https://stackoverflow.com/questions/50667371/docker-ps-output-formatting-list-only-names-of-running-containers
        for CUR_CONTAINER in $(docker ps --format '{{.Names}}' --filter "status=exited");
        do
            echo "--------------------------------------------------------------------------------"
            echo "Starting [${CUR_CONTAINER}] at $(date +'%d.%m.%Y-%H:%M:%S')"
            docker start "${CUR_CONTAINER}"
        done
        echo "================================================================================"
    fi
}

#+------------------------------------------------------------------------------+
#| Get list of containers having a volume
#+------------------------------------------------------------------------------+
function get_container_list {
    containerList=()
    for CUR_VOLUME in $(docker volume ls | tail -n +2 | cut -d ' ' -f 6);
    do
        CUR_CONTAINER=$(get_container_name "${CUR_VOLUME}")
        containerList+=(${CUR_CONTAINER})
    done
    containerList=($(for doc in "${containerList[@]}"; do echo "${doc}"; done | sort -u))
    echo "${containerList[@]}"
}

#+------------------------------------------------------------------------------+
#| Start backup                                                                 |
#+------------------------------------------------------------------------------+
echo "================================================================================"
echo "***** Start backup of docker volumes at [$(date +'%d.%m.%Y-%H:%M:%S')]"
echo ""
TME_START=$(date +%s)
for CUR_CONTAINER in $(get_container_list);
do
    CON_TME_START=$(date +%s)
    echo "--------------------------------------------------------------------------------"
    echo "Stop container [${CUR_CONTAINER}]"
    docker stop "${CUR_CONTAINER}"
    for CUR_VOLUME in $(docker volume ls | tail -n +2 | cut -d ' ' -f 6 | grep -i ${CUR_CONTAINER});
    do
        echo "Create backup of [${CUR_VOLUME}] at $(date +'%d.%m.%Y-%H:%M:%S')"
        create_backup "${CUR_VOLUME}" "${STR_EXT_ARCHIVE}" "${STR_DATE}"
        echo "Drop old backups of [${CUR_VOLUME}] at $(date +'%d.%m.%Y-%H:%M:%S')"
        drop_old_backups "${CUR_VOLUME}" "${STR_EXT_ARCHIVE}" "${INT_KEEP}"
    done
    echo "Start container [${CUR_CONTAINER}]"
    docker start "${CUR_CONTAINER}"
    CON_TME_END=$(date +%s)
    DURATION=$(get_duration $(($CON_TME_END-$CON_TME_START)))
    echo "Backup of [${CUR_CONTAINER}] volumes in ${DURATION}"
done
echo ""
start_not_running_container
TME_END=$(date +%s)
DURATION=$(get_duration $(($TME_END-$TME_START)))
echo "Backups done after ${DURATION}"
echo "================================================================================"
