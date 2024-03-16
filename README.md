# NAS

Some shell scripts used in conjunction with my NAS.

## docker_container_start.sh

Script to check for not running docker containers. If some containers found, they're started.

## docker_volume_backup.sh

Script to backup volumes of docker containsers. **NOTE:** If non running containers are found, they are started.

## pi-backup.sh

I've got a running [Pi-Hole][pihole] at home. I'm using this script to get a backup of the image. It's based on the `svnExport.sh` script. The command of the backup is inspired from [here][backup].

### Prerequisites of pi-backup.sh

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

On my DIY-NAS I've got a [SCM-Manager][SCM] running in a docker container. To backup the SVN repositories without knowing the number or names of them, I'm using this script.

This script is obsolete. Use [SCM-Backup][scm-backup] instead.

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
[OMV]: https://www.openmediavault.org
[SCM]: https://scm-manager.org/
[backup]: https://pixelfriedhof.com/raspberry-pi-remote-backup-ueber-ssh-per-terminal-anfertigen/
[pihole]: https://pi-hole.net/
[remote]: http://www.linuxproblem.org/art_9.html
[scm-backup]: https://github.com/ThirtySomething/SCM-Backup
