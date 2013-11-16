#!/bin/bash

#
# Helpful docs
# http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/x405.html
#


# Move the cursor to the bottom left, prints the given string, and restores state

function displayMessage {
	CMD="(_displayMessage \"$1\" \"$2\" \"$3\" \"$4\" \"$5\") ${5:+&}"
	echo "Executing command: $CMD"
	eval $CMD
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
function finish {

	TERMINATED_MSG="$0 completed at `date +'%r'`"
	displayMessage "$TERMINATED_MSG" "YES" $(( `tput lines` - 1 )) 0
	#if [ -z "$STANDARD_OUTPUT" ]; then
	#	sleep 1
	#	echo ""
	#fi

	# Restore prompt state
	PS1=$OLDPS1
}
trap finish EXIT
