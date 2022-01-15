# NAS

Some shell scripts used in conjunction with my NAS.

## pi-backup.sh

I've got a running [Pi-Hole][pihole] at home. I'm using this script to get a backup of the image. It's based on the `svnExport.sh` script. The command of the backup is inspired from [here][backup].

### Prerequisites

You need to have remote login without password enabled as described [here][remote].

### Setup

Before you can run the script, you have to adjust some variables. They are not passed as arguments. At the head of the script you can see

```bash
# Remote system and user
REM_USR=pi
REM_SYS=192.168.71.7
# Maximum number backups to keep
INT_KEEP=5
```

To adjust to your needs you have to change

- `REM_USR` => User of remote system
- `REM_SYS` => Name or IP of remote system
- `INT_KEEP` => Number of backups to keep

## svnExport.sh

On my NAS I've got a SVN server running. To backup my repositories without
knowing the number or names of them, I'm using this script.

### Setup

Before you can run the script, you have to adjust some variables. They are not passed as arguments. At the head of the script you can see

```bash
# location of all repositories
VAR_PATH_SVN=/volume1/subversion/*
# maximum days to keep a backup
INT_AGE=7
```

You have to change `VAR_PATH_SVN` to the location of your SVN root path where
your repositories resides. Changing `INT_AGE` is responsible for keeping n
versions of your backup files.

### Running

I'm running this script using the integrated task scheduler. Manually create a
job, run it as the user `root` and enter something like this:

```bash
bash /volume1/homes/<USER>/<PATH>/svnExport.sh >> /volume1/homes/<USER>/<PATH>/svnExport.log 2>&1
```

The exported files will locate in the same directory as this script. You may
need to change this...

### Processing

The process is just simple but I'll explain it anyway:

* Loop over all directories located in `VAR_PATH_SVN`
* In case of a SVN repository, perform a SVN dump and gzip the dump
  * The determination of a SVN repository requires root privileges
* In case a repository is dumped, cleanup the outdated backups

## SynopackageUninstall.sh

Synology has an internal search engine. This will read all files and build an
index of them. Unfortunately my [DS411slim][DS411slim] is an old one and lacks
performance to satisfy the usage of this search engine. Allthough I've
uninstalled this package several times, Synology re-installs it with each
firmware update. So I decided to write a script, added it in the scheduler and
possible remove this performance thief once a day.

Inside the task scheduler of DSM you need to create a manual entry, executed as
`root`:

```bash
bash /volume1/homes/<USER>/SynopackageUninstall.sh >> /volume1/homes/<USER>/SynopackageUninstall.log 2>&1
```

[DS411slim]: https://www.synology.com/en-global/company/news/article/Synology_Unveils_DiskStation_DS411slim
[backup]: https://pixelfriedhof.com/raspberry-pi-remote-backup-ueber-ssh-per-terminal-anfertigen/
[pihole]: https://pi-hole.net/
[remote]: http://www.linuxproblem.org/art_9.html