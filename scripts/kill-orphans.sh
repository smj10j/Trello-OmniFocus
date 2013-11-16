#!/bin/bash

# Only useful when debugging

ps aux | grep bash | grep -v "autodeployer.sh" | grep -v "\-bash" | awk '{print $2}' | xargs -L 1 kill -9