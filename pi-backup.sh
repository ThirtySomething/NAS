#!/bin/bash
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
REM_USR=pi
REM_SYS=192.168.71.7
# Maximum number backups to keep
INT_KEEP=5
# file extension
STR_EXT=gz
# current date
STR_DATE=$(date +%Y-%m-%d)
# get current name of backup folder
DIR_BACKUP=`dirname $0`
DIR_BACKUP=`realpath ${DIR_BACKUP}`

#+------------------------------------------------------------------------------+
#| Create name for the backup                                                   |
#+------------------------------------------------------------------------------+
function get_backup_name {
   echo "${DIR_BACKUP}/`basename ${1}`-${STR_DATE}.${STR_EXT}"
}

#+------------------------------------------------------------------------------+
#| Delete backups older than specified age                                      |
#+------------------------------------------------------------------------------+
function drop_old_backups {
    PATTERN=`basename ${1}`
    FTK=`expr 1 + ${INT_KEEP}`
    # The solution for keep the last x files is described here
    # https://stackoverflow.com/questions/25785/delete-all-but-the-most-recent-x-files-in-bash/25789
    echo "`date +'%Y%m%d-%H:%M:%S'`: Keep the last ${INT_KEEP} backups"
    # echo "ls ${DIR_BACKUP}/${PATTERN}*.${STR_EXT} -tp | grep -v '/$' | tail -n +${FTK} | tr '\n' '\0' | xargs -0 rm --"
    ls ${DIR_BACKUP}/${PATTERN}*.${STR_EXT} -tp | grep -v '/$' | tail -n +${FTK}
    ls ${DIR_BACKUP}/${PATTERN}*.${STR_EXT} -tp | grep -v '/$' | tail -n +${FTK} | tr '\n' '\0' | xargs -0 rm --
    echo ""
}

#+------------------------------------------------------------------------------+
#| Backup SD card                                                               |
#+------------------------------------------------------------------------------+
function backup_sd_card {
    VAR_DEST_NAME=$(get_backup_name ${1})
    echo "`date +'%Y%m%d-%H:%M:%S'`: Backup SD card [${1}] to [${VAR_DEST_NAME}]"
    ssh ${REM_USR}@${REM_SYS} "sudo dd if=/dev/mmcblk0 bs=1M | gzip -" | dd of=${VAR_DEST_NAME}
}

#+------------------------------------------------------------------------------+
#| Start backup                                                                 |
#+------------------------------------------------------------------------------+
echo "--------------------------------------------------------------------------------"
echo "***** Start backup of SD card at [${STR_DATE}]"
backup_sd_card "pi-hole"
drop_old_backups ${VAR_CURRENT_DIR}
echo ""
