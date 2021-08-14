#!/bin/bash
#+----------------------------------------------------------------------------+
#| Script to export configured svn repositories                               |
#+----------------------------------------------------------------------------+
# Comment line out for debugging purposes
# set -x
#+----------------------------------------------------------------------------+
#| Variable definitions                                                       |
#+----------------------------------------------------------------------------+
# location of all repositories
VAR_PATH_SVN=/volume1/subversion/*
# maximum days to keep a backup
INT_AGE=4
# file extension
STR_EXT=gz
# current date
STR_DATE=$(date +%Y-%m-%d)
# get current name of backup folder
DIR_EXPORT=`dirname $0`
DIR_EXPORT=`realpath ${DIR_EXPORT}`

#+----------------------------------------------------------------------------+
#| Check for valid SVN repository                                             |
#+----------------------------------------------------------------------------+
function is_svn_repository {
	svnlook info $1 > /dev/null 2>&1
	echo $?
}

#+----------------------------------------------------------------------------+
#| Create name for SVN directory for export                                   |
#+----------------------------------------------------------------------------+
function get_svn_destination_name {
   echo "$DIR_EXPORT/`basename $1`-$STR_DATE.$STR_EXT"
}

#+----------------------------------------------------------------------------+
#| Delete backups older than specified age                                    |
#+----------------------------------------------------------------------------+
function drop_old_exports {
    PATTERN=`basename $1`
	# The + on mtime points out INT_AGE days AND OLDER
	echo "`date +'%Y%m%d-%H:%M:%S'`: Delete backups older than ${INT_AGE} days"
	find ${DIR_EXPORT} -name \"${PATTERN}-*.${STR_EXT}\" -ctime +${INT_AGE}
	find ${DIR_EXPORT} -name "${PATTERN}-*.${STR_EXT}" -ctime +${INT_AGE} -delete
	echo ""
}

#+----------------------------------------------------------------------------+
#| Export SVN repository                                                      |
#+----------------------------------------------------------------------------+
function export_svn_repository {
	VAR_DEST_NAME=$(get_svn_destination_name $1)
	echo "`date +'%Y%m%d-%H:%M:%S'`: Dumping repo [$1] to [$VAR_DEST_NAME]"
	svnadmin dump $1 | gzip > $VAR_DEST_NAME
}

#+----------------------------------------------------------------------------+
#| Loop over all repositories                                                 |
#+----------------------------------------------------------------------------+
echo "***** Start export of SVN repositories for date [$STR_DATE]"
for VAR_CURRENT_DIR in $VAR_PATH_SVN
do
	if [[ $(is_svn_repository $VAR_CURRENT_DIR) -eq 1 ]]
	then
		echo "`date +'%Y%m%d-%H:%M:%S'`: Skip non SVN repository [$VAR_CURRENT_DIR]."
		echo ""
	else
		export_svn_repository $VAR_CURRENT_DIR
		drop_old_exports $VAR_CURRENT_DIR
	fi
done
echo ""
