#!/bin/bash

LOCAL_DIR=src
DEPLOY_CMD="./scripts/deploy.sh $LOCAL_DIR"


echo "Performing initial sync..."
$DEPLOY_CMD

while true; do
	echo "Watching '$LOCAL_DIR' for changes ("`date`")..."
	if [ -z "`which inotifywait`" ]; then
		./lib/fswatch/fswatch $LOCAL_DIR "$DEPLOY_CMD"
	else
		inotifywait $LOCAL_DIR && $DEPLOY_CMD
	fi
done