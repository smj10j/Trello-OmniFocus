#!/bin/bash

#
# Helpful docs
# Cursor positioning: http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/x405.html
# Function rewriting: http://unix.stackexchange.com/questions/29689/how-do-i-redefine-a-bash-function-in-terms-of-old-definition
#
# Example that can be run in terminal:
# 
# clear; NEW_FINISH_BODY='echo "hello $1"'; OLD_FINISH_BODY='echo "goodbye $1"'; X="function finish { 
# $NEW_FINISH_BODY
# $OLD_FINISH_BODY
# }"; 
# echo "X: $X"; eval "$X"; echo "declared: $(declare -f finish)"; finish "what's my name"
#
#

# Common options we want to snipe
while getopts ":vs" o; do
	case "${o}" in
		v)
			VERBOSE='-v'
			;;
		s)
			STANDARD_OUTPUT='-s'
			;;
		h) 
			usage
			;; 
	esac
done

# Determine if we're the parent of child of another bash script
PID=$$
PARENT_PROCESS_NAME=`ps -p $PPID | grep $PPID | awk '{print $4}'`
IS_PARENT=''
if [ "$PARENT_PROCESS_NAME" == "-bash" ]; then
	IS_PARENT='yes'
fi

# X,Y levels for messages
Y_CURRENT_TIME='0'
Y_STICKY_STATUS='1'
Y_STATUS="$(( `tput lines` - 1 ))"

X_RIGHT='$(( `tput cols` - ${#MSG} - 1 ))'
X_LEFT='0'



# Move the cursor to the bottom left, prints the given string, and restores state
function displayMessage {

	MSG=$1
	
	# (msg, x, y)
	if [ $# -le 3 ]; then
		CAN_DISPLAY=''
		X=${2:-$X_LEFT}
		Y=${3:-$Y_STATUS}
	else 
		CAN_DISPLAY=$2
		X=${3:-$X_LEFT}
		Y=${4:-$Y_STATUS}
	fi
					
	# Expand variables
	# echo "Expanding for MSG=$MSG, X=$X, Y=$Y"
	X=`eval echo $X`
	Y=`eval echo $Y`

	# echo "displayMessage $MSG CAN_DISPLAY:$CAN_DISPLAY VERBOSE:$VERBOSE  $X $Y"
	
	# Display
	_displayMessage "$MSG" "$CAN_DISPLAY" "$X" "$Y"
}

#TODO: this drawing function is poor 
#Should just hold a list of all elements on the screen and redraw when needed
function _displayMessage {

	MSG=$1
	CAN_DISPLAY=$2
	X=$3
	Y=$4
	
	# echo "_displayMessage $MSG CAN_DISPLAY:$CAN_DISPLAY VERBOSE:$VERBOSE  $X $Y "
	
	CAN_DISPLAY=${VERBOSE:-$CAN_DISPLAY}
	if [ -n "$CAN_DISPLAY" ]; then 
		if [ -n "$STANDARD_OUTPUT" ]; then
			#tput ech `tput cols`
			echo $MSG
		else 			
			tput cup $Y $X
			echo -n $MSG
			tput cup $Y 0
		fi
		

	fi
}

# Handle cleanup

CHILDREN_PIDS=()
function addChildPID {
	# displayMessage "Added childPid=$1" "$X_LEFT" "$Y_STATUS" 
	CHILDREN_PIDS+=($1)
}

function addFinishFunction {

	NEW_FINISH_PREFIX=$1
	NEW_FINISH_SUFFIX=$2

	if [ "$NEW_FINISH_PREFIX" == '' -a "$NEW_FINISH_SUFFIX" == '' ]; then
		echo "You must supply either a prefix or suffix function to addFinishFunction(prefix,suffix)"
		cleanupAndExit 1
	fi
	
	NEW_FINISH_PREFIX=${NEW_FINISH_PREFIX#*\{}
	NEW_FINISH_PREFIX=${NEW_FINISH_PREFIX%\}}
	
	NEW_FINISH_SUFFIX=${NEW_FINISH_SUFFIX#*\{}
	NEW_FINISH_SUFFIX=${NEW_FINISH_SUFFIX%\}}

	if [ -n "`type -t finish`" ]; then
		OLD_FINISH_BODY=$(declare -f finish)
		OLD_FINISH_BODY=${OLD_FINISH_BODY#*\{}
		OLD_FINISH_BODY=${OLD_FINISH_BODY%\}}
	else
		OLD_FINISH_BODY=":"
	fi

	FINISH_FUNCTION="function finish { \
		$NEW_FINISH_PREFIX\
		$OLD_FINISH_BODY\
		$NEW_FINISH_SUFFIX\
	}"
	# echo "Will eval: $FINISH_FUNCTION"
	eval "$FINISH_FUNCTION"
	# echo "Installed new finish function: $(declare -f finish)"
	
}

function cleanupAndExit {
	STATUS=$1
	
	function trapErrorHandler { 
		:; 
	}
	
	exit $STATUS
}

function finish {
	if [ -n "$IS_PARENT" ]; then
		displayMessage "$0 completed at `date +'%r'`" "$X_RIGHT" "$Y_STATUS" 
		# if [ -z "$STANDARD_OUTPUT" ]; then
		#	 sleep 1
		#	 echo ""
		# fi
	fi
	
	if [ ${#CHILDREN_PIDS[@]} -gt 0 ]; then
		# displayMessage "Terminating $0's ${#CHILDREN_PIDS[@]} children..." "$X_LEFT" "$Y_STATUS" 
		for childPid in "${CHILDREN_PIDS[@]}"; do 
			RESULT="$(kill $childPid 2>&1)"
			# displayMessage "Killing child $childPid: $RESULT" "$X_LEFT" "$Y_STATUS" 
		done
	fi
}
trap finish EXIT


### Error Handler ###
function trapErrorHandler {
	finish

	MYSELF="$0"					# equals to my script name
	LASTLINE="$1"				# argument 1: last line of error occurence
	LASTERR="$2"				# argument 2: error code of last command
	
	# clear
	echo ""
	echo "------------- ERROR -------------"
	echo "${MYSELF}: line ${LASTLINE}: exit status of last command: ${LASTERR}"
	echo "---------------------------------"
	echo ""

	cleanupAndExit 1
}
trap 'trapErrorHandler ${LINENO} $?' ERR





# If we're the parent process, set up display params
if [ -n "$IS_PARENT" ]; then
	if [ -z "$STANDARD_OUTPUT" ]; then
	
		# Create our space
		tput clear
	
		# Save prompt state and clear it
		tput sc
		OLDPS1=$PS1
		PS1=""
	
		# Restore prompt state on exit
		function new_finish {
			PS1=$OLDPS1
			tput rc
		}
		addFinishFunction "" "$(declare -f new_finish)"
	fi
fi


#displayMessage "Started $0 | PID: $PID | PPID: $PPID | IS_PARENT: $IS_PARENT |  VERBOSE:$VERBOSE | STANDARD_OUTPUT:$STANDARD_OUTPUT | ARGS($#): $*" "$X_LEFT" "$Y_STATUS" 

