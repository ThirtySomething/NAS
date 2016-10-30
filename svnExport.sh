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
INT_AGE=7
# file extension
STR_EXT=tgz
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
   echo "$DIR_EXPORT/`basename $1`-$STR_DATE.svn.$STR_EXT"
}

#+----------------------------------------------------------------------------+
#| Export SVN repository                                                      |
#+----------------------------------------------------------------------------+
function export_svn_repository {
	VAR_DEST_NAME=$(get_svn_destination_name $1)
	echo "Dumping repo [$1] to [$VAR_DEST_NAME]"
	svnadmin dump $1 | gzip > $VAR_DEST_NAME
}

#+----------------------------------------------------------------------------+
#| Delete backups older than specified age                                    |
#+----------------------------------------------------------------------------+
function drop_old_exports {
	# The + on mtime points out INT_AGE days AND OLDER
	find ${DIR_EXPORT} -name "*.$STR_EXT" -mtime +${INT_AGE} -exec rm {} \;
	echo "Deleted backups older than ${INT_AGE} days"
}

#+----------------------------------------------------------------------------+
#| Loop over all repositories                                                 |
#+----------------------------------------------------------------------------+
INT_EXPORTCOUNT=0
for VAR_CURRENT_DIR in $VAR_PATH_SVN
do
	if [[ $(is_svn_repository $VAR_CURRENT_DIR) -eq 1 ]]
	then
		echo "Skip non SVN repository [$VAR_CURRENT_DIR]."
	else
		export_svn_repository $VAR_CURRENT_DIR $VAR_SVN_USER $VAR_SVN_PWD
		INT_EXPORTCOUNT=$((INT_EXPORTCOUNT+1))
	fi
done

#+----------------------------------------------------------------------------+
#| Cleanup old backups                                                        |
#+----------------------------------------------------------------------------+

if [[ $INT_EXPORTCOUNT -gt 0 ]]
then
	drop_old_exports
fi