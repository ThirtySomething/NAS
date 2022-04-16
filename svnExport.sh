#!/bin/bash
#+-----------------------------------------------------------------------------+
#| Script to export configured svn repositories                                |
#+-----------------------------------------------------------------------------+
# Comment line out for debugging purposes
# set -x
#+-----------------------------------------------------------------------------+
#| Variable definitions                                                        |
#+-----------------------------------------------------------------------------+
# location of all repositories
VAR_PATH_SVN="/srv/dev-disk-by-uuid-44c66e2f-7122-4c7c-9b2a-258139e35584/docker/volumes/scmmanager/_data/repositories/*"
# suffix for SCM organized repositories
SUFFIX_SVN=data
# filename containing real repository name
META_SVN=metadata.xml
# maximum days to keep a backup
INT_AGE=5
# file extension
STR_EXT=gz
# current date
STR_DATE=$(date +%Y-%m-%d)
# get current name of backup folder
DIR_EXPORT=$(dirname "${0}")
DIR_EXPORT=$(realpath "${DIR_EXPORT}")

#+-----------------------------------------------------------------------------+
#| Check for valid SVN repository                                              |
#+-----------------------------------------------------------------------------+
function is_svn_repository {
    svnlook info "${1}" >/dev/null 2>&1
    echo $?
}

#+-----------------------------------------------------------------------------+
#| Get base name for SVN repository                                            |
#+-----------------------------------------------------------------------------+
function get_svn_base_name {
    REPOBASE="$(dirname "${1}")/${META_SVN}"
    REPONAME=$(xmlstarlet sel -T -t -m "/repositories/name" -v "/repositories/name" < "${REPOBASE}")
    echo "${REPONAME}"
}

#+-----------------------------------------------------------------------------+
#| Create name for SVN respoistory for export                                  |
#+-----------------------------------------------------------------------------+
function get_svn_destination_name {
    REPOBASE=$(get_svn_base_name "${1}")
    echo "${DIR_EXPORT}/${REPOBASE}-${STR_DATE}.${STR_EXT}"
}

#+-----------------------------------------------------------------------------+
#| Delete backups older than specified age                                     |
#+-----------------------------------------------------------------------------+
function drop_old_exports {
    PATTERN=$(get_svn_base_name "${1}")
    FTK=$((1 + "${INT_AGE}"))
    echo "$(date +'%Y%m%d-%H:%M:%S'): Keep the last ${INT_AGE} backups"
    COUNTER=0
    for CURRENT_DUMP in $(find "${DIR_EXPORT}" -name "${PATTERN}-*.${STR_EXT}" | sort -nr); do
        if [[ "${COUNTER}" -lt "${FTK}" ]]; then
            echo "Keep dump [${CURRENT_DUMP}]"
        else
            echo "Delete dump [${CURRENT_DUMP}]"
            rm "${CURRENT_DUMP}"
        fi
        COUNTER=$((COUNTER + 1))
    done
    echo ""
}

#+-----------------------------------------------------------------------------+
#| Export SVN repository                                                       |
#+-----------------------------------------------------------------------------+
function export_svn_repository {
    VAR_DEST_NAME=$(get_svn_destination_name "${1}")
    echo "$(date +'%Y%m%d-%H:%M:%S'): Dumping repo [${1}] to [${VAR_DEST_NAME}]"
    svnadmin dump "${1}" | gzip > "${VAR_DEST_NAME}"
}

#+-----------------------------------------------------------------------------+
#| Loop over all repositories                                                  |
#+-----------------------------------------------------------------------------+
echo "--------------------------------------------------------------------------------"
echo "***** Start export of SVN repositories for date [${STR_DATE}]"
for VAR_CURRENT_DIR in ${VAR_PATH_SVN}; do
    SVN_REPO="${VAR_CURRENT_DIR}/${SUFFIX_SVN}"
    if [[ $(is_svn_repository "${SVN_REPO}") -eq 1 ]]; then
        echo "$(date +'%Y%m%d-%H:%M:%S'): Skip non SVN repository [${SVN_REPO}]."
        echo ""
    else
        export_svn_repository "${SVN_REPO}"
        drop_old_exports "${SVN_REPO}"
    fi
done
echo ""
