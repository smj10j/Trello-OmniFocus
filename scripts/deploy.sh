#!/bin/bash

LOCAL_DIR=src

REMOTE_HOST=conquerllc.com
REMOTE_USER=root
REMOTE_DIR=/usr/share/nginx/www/trello-omnifocus

echo "Deploying contents of '"$LOCAL_DIR"' to '"$REMOTE_DIR"' on $REMOTE_HOST as user $REMOTE_USER"
scp -pr $LOCAL_DIR/* $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/