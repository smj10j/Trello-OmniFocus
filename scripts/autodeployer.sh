#!/bin/bash

# Options and Usage

usage() { 
	echo -e "\
Usage: $0 [-p <path>] [-q] [-h]\n\
Options:\n\
	-p <path>       Path to watch and deploy from (default: src)\n\
	-q              Quiet mode\n\
	-h              Show this help\n" 1>&2; 
	exit 1;
}

while getopts ":qp:" o; do
    case "${o}" in
        q)
            QUIET='-q'
            ;;
        p)
            DIR=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${DIR}" ]; then
    DIR=src
fi






# Functionality starts here

DEPLOY_CMD="./scripts/deploy.sh -p $DIR $QUIET"

echo "Performing initial sync with DEPLOY_CMD=$DEPLOY_CMD..."
$DEPLOY_CMD

while true; do
	if [ -z "$QUIET" ]; then echo "Watching '$DIR' for changes ("`date`")..."; fi
	if [ -z "`which inotifywait`" ]; then
		./lib/fswatch/fswatch $DIR "$DEPLOY_CMD"
	else
		inotifywait $DIR && $DEPLOY_CMD
	fi
done