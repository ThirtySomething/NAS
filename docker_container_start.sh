#!/usr/bin/bash
#+------------------------------------------------------------------------------+
#| Script to start not running docker containers                                |
#+------------------------------------------------------------------------------+
# Comment line out for debugging purposes
# set -x
#+------------------------------------------------------------------------------+
#| Variable definitions                                                         |
#+------------------------------------------------------------------------------+

#+------------------------------------------------------------------------------+
#| Start not running docker containers                                          |
#+------------------------------------------------------------------------------+
STP_CONTAINER=$(docker ps --format '{{.Names}}' --filter "status=exited" | wc -l)
if [ "${STP_CONTAINER}" -gt "0" ]
then
    echo "================================================================================"
    echo "***** Starting not running docker container(s) at $(date +'%Y%m%d-%H:%M:%S')"
    echo ""
    # List existing docker containers names only
    # https://stackoverflow.com/questions/50667371/docker-ps-output-formatting-list-only-names-of-running-containers
    for CUR_CONTAINER in $(docker ps --format '{{.Names}}' --filter "status=exited");
    do
        echo "--------------------------------------------------------------------------------"
        echo "Starting [${CUR_CONTAINER}] at $(date +'%Y%m%d-%H:%M:%S')"
        docker start "${CUR_CONTAINER}"
    done
    echo "================================================================================"
fi
