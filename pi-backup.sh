#!/usr/bin/bash
#+------------------------------------------------------------------------------+
#| Script to backup the SD card of a pi                                         |
#| Prerequisites:                                                               |
#| - Remote login with ssh see: https://rb.gy/2dvh7g                            |
#| - Remote backup: https://rb.gy/qatp5b                                        |
#+------------------------------------------------------------------------------+
# Comment line out for debugging purposes
# set -x
#+------------------------------------------------------------------------------+
#| Variable definitions                                                         |
#+------------------------------------------------------------------------------+
# Remote system and user
REM_USR=root
REM_SYS=192.168.71.7
# Maximum number backups to keep
INT_KEEP=5
# Name of backup
NAME_BACKUP=pi-hole
# File extension
STR_EXT=gz
# current date
STR_DATE=$(date +%Y-%m-%d)
# Get current name of backup folder
DIR_BACKUP=$(dirname "${0}")
DIR_BACKUP=$(realpath "${DIR_BACKUP}")
if [ -n "$1" ]
then
    DIR_BACKUP=${1}
fi

#+------------------------------------------------------------------------------+
#| Create name for the backup                                                   |
#+------------------------------------------------------------------------------+
function get_backup_name {
    echo "${DIR_BACKUP}/$(basename "${1}")/$(basename "${1}")-${2}.${STR_EXT}"
}

#+------------------------------------------------------------------------------+
#| Delete backups older than specified age                                      |
#+------------------------------------------------------------------------------+
function drop_old_backups {
    PATTERN=$(get_backup_name "${1}" "*")
    FTK=$(expr 0 + ${INT_KEEP})
    echo "$(date +'%Y%m%d-%H:%M:%S'): Delete old backups"
    for datei in $(ls -S -t -1 ${PATTERN}); do
        if [ 0 -eq "${FTK}" ]; then
            rm -f "${datei}"
        	echo "File [${datei}] deleted"
        else
            let "FTK-=1"
        fi
    done
    echo ""
}

#+------------------------------------------------------------------------------+
#| Backup SD card                                                               |
#+------------------------------------------------------------------------------+
function backup_sd_card {
    VAR_DEST_NAME=$(get_backup_name "${1}" "${2}")
    echo "$(date +'%Y%m%d-%H:%M:%S'): Backup SD card [${1}] to [${VAR_DEST_NAME}]"
    ssh ${REM_USR}@${REM_SYS} "sudo dd if=/dev/mmcblk0 bs=1M | gzip -" | dd of="${VAR_DEST_NAME}"
    # dd if=/dev/mmcblk0 bs=32M | gzip - | dd of=${VAR_DEST_NAME}
    echo ""
}

#+------------------------------------------------------------------------------+
#| Start backup                                                                 |
#+------------------------------------------------------------------------------+
echo "--------------------------------------------------------------------------------"
echo "***** Start backup of SD card at [${STR_DATE}]"
mkdir -p "${DIR_BACKUP}/${NAME_BACKUP}"
backup_sd_card "${NAME_BACKUP}" "${STR_DATE}"
drop_old_backups "${NAME_BACKUP}"
echo ""
