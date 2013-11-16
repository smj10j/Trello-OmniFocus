#!/bin/bash

# Options and Usage

usage() { 
	echo -e "\
Usage: $0 [-p <path>] [-q] [-h]\n\
Options:\n\
	-p <path>       Path to deploy from\n\
	-q              Quiet mode\n\
	-h              Show this help\n" 1>&2; 
	exit 1;
}

while getopts ":qp:" o; do
    case "${o}" in
        q)
            QUIET=1
            ;;
        p)
            D=${OPTARG%*/}
            if [[ $D == */* ]]; then 
            	PARENT_DIR=`dirname $D`
            	LOCAL_DIR=${D/$PARENT_DIR\/}
            else
	            LOCAL_DIR=$D
				PARENT_DIR=`pwd`
            fi
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "$LOCAL_DIR" ];then
	usage
fi



# Functionality starts here

REMOTE_HOST=conquerllc.com
REMOTE_USER=root
REMOTE_WEB_DIR=/usr/share/nginx/www
REMOTE_DIR=trello-omnifocus

NOTIFIER_OPEN_URL="http://$REMOTE_HOST/$REMOTE_DIR"
NOTIFIER_GROUP_ID="$PARENT_DIR/$LOCAL_DIR.autodeployer"
NOTIFIER_DIR_DISPLAY_NAME="${PARENT_DIR##*/}/$LOCAL_DIR"

if [ -z "$QUIET" ]; then echo echo ""; fi
if [ -z "$QUIET" ]; then echo echo "------- Deployment of $NOTIFIER_DIR_DISPLAY_NAME started -------"; fi
if [ -z "$QUIET" ]; then echo echo "Deploying contents of '"$LOCAL_DIR"' to '"$REMOTE_DIR"' on $REMOTE_HOST as user $REMOTE_USER"; fi

RESULTS=`rsync -av $LOCAL_DIR/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_WEB_DIR/$REMOTE_DIR/`
TMP=${RESULTS#sending incremental file list*}
FILE_LIST=`echo "${TMP%sent*}" | tr -d ' '`

if [ -n "$FILE_LIST" ]; then
	if [ -n "`which growlnotify`" ]; then
		growlnotify -t "Deployed $NOTIFIER_DIR_DISPLAY_NAME" -m "$FILE_LIST" -d "$NOTIFIER_GROUP_ID" --appIcon "Google Chrome" --url "$NOTIFIER_OPEN_URL"
	elif [ -n "`which terminal-notifier`" ]; then
		terminal-notifier -title "Deployed $NOTIFIER_DIR_DISPLAY_NAME" -subtitle "$FILE_LIST" -group "$NOTIFIER_GROUP_ID" --appIcon "Google Chrome" -open "$NOTIFIER_OPEN_URL"
	fi
fi

echo "------- Deployed $NOTIFIER_DIR_DISPLAY_NAME -------"
if [ -z "$QUIET" ]; then echo echo ""; fi


