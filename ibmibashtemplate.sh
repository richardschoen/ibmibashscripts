#!/QOpenSys/pkgs/bin/bash
#----------------------------------------------------------------
# Script name: ibmibashtemplate.sh
# Purpose: This is a starter bash template - Enter program desc/purpose here
# Parameters: See the usage() function
#---------------------------------------------------------------- 

#Blow up on any errors - Uncomment this for global error trapping
#set -e

PROGNAME=$(basename $0) #Capture base script name

# ---------------------------------------------------------------- 
# Functions
# ---------------------------------------------------------------- 

function usage() {
#----------------------------------------------------------------
# Function to show command line usage 
#----------------------------------------------------------------
    SCRIPT="$(basename -- $0)"
    echo -e "\
Usage:\t$SCRIPT [options]
Desc: This is the purpose of the program

OPTIONS
  -h, --help       Display this help text
  -l, --library    IBM i library                 **required**
  -f, --file       IBM i source file             **required**
  -m, --member     IBM i source member           **required**
  -d, --outputdir  IBM i IFS output directory    **required**"
}

print_cli_error() {
#----------------------------------------------------------------
# Function to print cli error 
#----------------------------------------------------------------   
    echo -e "\e[31m$1\n\e[39m"
    usage
    exit 1
}

function error_exit
{
#----------------------------------------------------------------
# Function for exit due to fatal program error
# Accepts 1 argument:
# string containing descriptive error message
#---------------------------------------------------------------- 

    echo "//-----------------------------------------------------------"    
    echo "//${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
    echo "//-----------------------------------------------------------"
    exit 1
}

# ---------------------------------------------------------------- 
# Loop to extract the command line parms and make sure all required are specified
# ---------------------------------------------------------------- 
for opts in "$@"
do
case $opts in
    -h | --help) # Show command usage
       usage
       exit
       ;;

    -l=*|--library=*)
       LIBRARY="${opts#*=}"
       shift # past argument=value
       ;;
    -f=*|--file=*)
       FILE="${opts#*=}"
       shift # past argument=value
       ;;
    -m=*|--member=*)
       MEMBER="${opts#*=}"
       shift # past argument=value
       ;;
    -o=*|--outputdir=*)
       OUTPUTDIR="${opts#*=}"
       shift # past argument=value
       ;;
    --default)
       DEFAULT=YES
       shift # past argument with no value
       ;;
    *)
          # unknown option
    ;;
esac
done

# ---------------------------------------------------------------- 
# Make sure required parms are specified. Bail out if not.
# ---------------------------------------------------------------- 
if [[ -z "$LIBRARY" || -z "$FILE" ||-z "$MEMBER" || -z "$OUTPUTDIR"  ]]; then
    # Output the required parm selected values for reference
    echo "Current parameter values:"
    echo "LIBRARY     = $LIBRARY"
    echo "FILE        = $FILE"
    echo "MEMBER      = $MEMBER"
    echo "OUTPUTDIR   = $OUTPUTDIR"
    ERROR="ERROR: Missing at least one required option"
    REQUIRED="[-l,--library] [-f,--file] [-m,--member] [-o,--outputdir]"
    print_cli_error "$ERROR\nRequired options: $REQUIRED"
fi

# Example inline START output to STDOUT for logging
STARTTIME=$(date)
echo "-----------------------------------------------------------"
echo "Start Listing source for library $LIBRARY/$FILE.$MEMBER to IFS dir $OUTPUTDIR - $(date)"
echo "-----------------------------------------------------------"

# Example iterating a file line by line
# Display the list by iterating through the text file
##while IFS= read -r line 
##do
##      echo "${line}" 
##done < "$DIRLISTFILE"

# Example inline END output to STDOUT for logging
# TODO - Possibly add elapsed time if needed
ENDTIME=$(date)
echo "-----------------------------------------------------------"
echo "End Listing source for library $LIBRARY/$FILE.$MEMBER to IFS dir $OUTPUTDIR - $(date)"
echo "Start time: $STARTTIME : End time: $ENDTIME"
echo "-----------------------------------------------------------"
