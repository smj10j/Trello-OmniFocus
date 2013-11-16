#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/include.sh"

# Options and Usage
usage() { 
	echo -e "\
Usage: $0 [-v] [-s] [-h] <path>\n\
Options:\n\
	path            Path to watch and deploy from (default: src)\n\
	-s              Standard output mode (not on one screen)\n\
	-v              Verbose mode\n\
	-h              Show this help\n" 2>&1; 
	cleanupAndExit 1;
}

# Positional arguments
DIR=`echo "${@:$OPTIND:1}" | tr -d '"'`
DIR=${DIR:-src}
shift $(($OPTIND - 1))

# This function allows us to perform update actions while the script is indefinitely running
function monitor {
	while true
	do
		displayMessage "Time: `date +'%r'`" "YES" "$X_RIGHT" "$Y_CURRENT_TIME"
		sleep 1
	done
}

if [ -z "$STANDARD_OUTPUT" ]; then
	# Start our monitor in the background
	monitor &

	# Save monitor() PID
	addChildPID $!
fi


###### Change Monitoring & Deployment #######

DEPLOY_CMD="./scripts/deploy.sh $VERBOSE $STANDARD_OUTPUT \"$DIR\" 2>&1"

displayMessage "Watching '$DIR' for changes (`date`)..." "YES" "$X_LEFT" "$Y_STATUS" 
displayMessage "Performing initial sync..." "YES" "$X_LEFT" "$Y_STATUS" 
$DEPLOY_CMD
displayMessage "" "YES" "$X_LEFT" "$Y_STATUS" 


while true; do
	displayMessage "Watching '$DIR' for changes (`date`)..." "YES" "$X_LEFT" "$Y_STATUS" 
	if [ -z "`which inotifywait`" ]; then
		./lib/fswatch/fswatch $DIR "$DEPLOY_CMD"
	else
		inotifywait $DIR && $DEPLOY_CMD
	fi
done

