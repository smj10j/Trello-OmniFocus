#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/include.sh"

# Options and Usage
usage() { 
	echo -e "\
Usage: $0 [-v] [-s] [-h] path\n\
Options:\n\
	path            Path to deploy from\n\
	-s              Standard output mode (not on one screen)\n\
	-v              Verbose mode\n\
	-h              Show this help\n" 2>&1; 
	cleanupAndExit 1;
}

# Positional arguments
DIR=`echo "${@:$OPTIND:1}" | tr -d '"'`
DIR=${DIR%*/}
if [[ $DIR == */* ]]; then 
	PARENT_DIR=`dirname $DIR`
	LOCAL_DIR=${DIR/$PARENT_DIR\/}
else
	LOCAL_DIR=$DIR
	PARENT_DIR=`pwd`
fi
shift $(($OPTIND - 1))

if [ -z "$LOCAL_DIR" ]; then usage; fi



###### Deployment #######

REMOTE_HOST=conquerllc.com
REMOTE_USER=root
REMOTE_WEB_DIR=/usr/share/nginx/www
REMOTE_DIR=trello-omnifocus

NOTIFIER_OPEN_URL="http://$REMOTE_HOST/$REMOTE_DIR"
NOTIFIER_GROUP_ID="$PARENT_DIR/$LOCAL_DIR.autodeployer"
NOTIFIER_DIR_DISPLAY_NAME="${PARENT_DIR##*/}/$LOCAL_DIR"

displayMessage "Deploying contents of '$NOTIFIER_DIR_DISPLAY_NAME' to '$REMOTE_DIR' on $REMOTE_HOST as user $REMOTE_USER" "YES" "$X_LEFT" "$Y_STATUS"

RESULTS=`rsync -av $LOCAL_DIR/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_WEB_DIR/$REMOTE_DIR`
TMP=${RESULTS#sending incremental file list*}
FILE_LIST=`echo "${TMP%sent*}" | tr -d ' '`

if [ -n "$FILE_LIST" ]; then
	if [ -n "`which growlnotify`" ]; then
		growlnotify -t "Deployed $NOTIFIER_DIR_DISPLAY_NAME" -m "$FILE_LIST" -d "$NOTIFIER_GROUP_ID" --appIcon "Google Chrome" --url "$NOTIFIER_OPEN_URL"
	elif [ -n "`which terminal-notifier`" ]; then
		terminal-notifier -title "Deployed $NOTIFIER_DIR_DISPLAY_NAME" -subtitle "$FILE_LIST" -group "$NOTIFIER_GROUP_ID" --appIcon "Google Chrome" -open "$NOTIFIER_OPEN_URL"
	fi
fi

displayMessage "Last Deploy: `date +'%r'`" "YES" "$X_RIGHT" "$Y_STICKY_STATUS"
#displayMessage "" "YES" "$X_LEFT" "$Y_STATUS"

cleanupAndExit 0
