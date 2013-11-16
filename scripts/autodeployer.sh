#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/include.sh"

# Options and Usage

usage() { 
	echo -e "\
Usage: $0 [-p <path>] [-v] [-s] [-h]\n\
Options:\n\
	-p <path>       Path to watch and deploy from (default: src)\n\
	-s              Standard output mode (not on one screen)\n\
	-v              Verbose mode\n\
	-h              Show this help\n" 1>&2; 
	exit 1;
}

while getopts ":vsp:" o; do
    case "${o}" in
        v)
            VERBOSE='-v'
            ;;
        s)
            STANDARD_OUTPUT='-s'
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

# Defaults
DIR=${DIR:-src}

# This function allows us to perform update actions while the script is indefinitely running
function monitor {

	# Create our space
	for i in {1..5}; do echo ""; done

	while true
	do
		TIME_MSG="Time: `date +'%r'`"
		displayMessage "$TIME_MSG" "" $(( `tput lines` - 2 )) $(( `tput cols` - ${#TIME_MSG} ))
		sleep 1
	done
}

# Start our monitor in the background
monitor &

# Save monitor() PID
addChildPID $!

# Handle cleanup
FINISH_FUNCTION=$(cat << 'EOF'
	echo "$0 completed at `date +'%r'`"
EOF
)
addFinishFunction "$FINISH_FUNCTION"


###### Change Monitoring & Deployment #######

DEPLOY_CMD="./scripts/deploy.sh -p $DIR $VERBOSE"
function deploy {
	$DEPLOY_CMD
}

displayMessage "Performing initial sync with DEPLOY_CMD=$DEPLOY_CMD..." "YES" 0 0 3
deploy

while true; do
	displayMessage "Watching '$DIR' for changes (`date`)..." "YES"
	if [ -z "`which inotifywait`" ]; then
		./lib/fswatch/fswatch $DIR "deploy"
	else
		inotifywait $DIR && deploy
	fi
done

