## svnExport.sh ##

On my NAS I've got an SVN server running. To backup my repositories without knowing the number of them, I'm using this script.

## Setup ##

Before you can run the script, you have to adjust some variables. Because I'm a lazy guy, I don't pass them as parameters. At the head of the script you can see

<pre>
  # location of all repositories
  VAR_PATH_SVN=/volume1/subversion/*
  # maximum days to keep a backup
  INT_AGE=7
</pre>

You have to change `VAR_PATH_SVN` to the location of your SVN root path where your repositories resides.<br>
Changing `INT_AGE` is responsible for keeping n versions of your backup files.

## Running ##

I'm running this script as a cronjob. The entry looks like this one

<pre>
30 3 * * * root /bin/sh svnExport.sh >> svnExport.log #SVN Export
</pre>

This means that every day at half past three the backup is started.

## Processing ##

The process is just simple but I'll explain it anyway:

* Loop over all directories located in `VAR_PATH_SVN`
* In case of a SVN repository, perform a SVN dump and gzip the dump
* In case a repository is dumped, cleanup the outdated backups

## Drawbacks ##

* The cleanup of the outdated backups is not repository specific