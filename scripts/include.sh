#!/bin/bash

#
# Helpful docs
# Cursor positioning: http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/x405.html
# Function rewriting: http://unix.stackexchange.com/questions/29689/how-do-i-redefine-a-bash-function-in-terms-of-old-definition
#


# Move the cursor to the bottom left, prints the given string, and restores state

function displayMessage {
	if [ -n "$5" ]; then
		CMD="(_displayMessage \"$1\" \"$2\" \"$3\" \"$4\" \"$5\") &"
		eval $CMD
		PID=$!
		addChildPID $PID
	else
		_displayMessage "$1" "$2" "$3" "$4"
	fi
}

function _displayMessage {
	CAN_DISPLAY=${VERBOSE:-$2}
	if [ -n "$CAN_DISPLAY" ]; then 
	
		if [ -n "$5" ]; then 
			sleep $5
			echo "Woke up after sleeping for $5 seconds to display message \"$1\""
		fi
	
		if [ -n "$STANDARD_OUTPUT" ]; then
			echo $1
		else 
			tput sc

			tput el
			tput el1
			
			tput cup ${3:-$(( `tput lines` - 2 ))} ${4:-0}
			echo -n $1
	
			tput rc
		fi
	fi
}

function clearMessage {
	displayMessage "" "" "$3" "$4"
}

# Save prompt state and clear it
OLDPS1=$PS1
PS1=""

# Handle cleanup

CHILDREN_PIDS=()
function addChildPID {
	CHILDREN_PIDS+=($1)
}

function addFinishFunction {
	if [ -z "$1" ]; then
		echo "You must supply a function as the first argument to addFinishFunction(function)";
		exit 1
	fi

	if [ -n "`type -t abc`" ]; then
		OLD_FINISH_BODY=$(declare -f finish)
		OLD_FINISH_BODY=${OLD_FINISH_BODY#*\{}
		OLD_FINISH_BODY=${OLD_FINISH_BODY%\}\}
	else
		OLD_FINISH_BODY="#Not previously defined"
	fi

	eval "finish () {\
	  $NEW_FINISH_BODY\
	  $OLD_FINISH_BODY\
	}"
}

