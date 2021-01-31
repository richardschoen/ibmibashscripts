#!/QOpenSys/pkgs/bin/bash
#----------------------------------------------------------------
# Script name: pingi.sh
# Purpose: Run PING CL System Command to see if host responds
# QSH/PASE do not have a ping command so we have to use the 
# regular IBM i PING CL command from PASE. Who knew :-)
# Parameters:
# 1.) Host Name or IP Address
# Exits:
# 0=Normal - No errors. Ping was successful.
# Non-zero - Errors occuured.
#---------------------------------------------------------------- 

PATH="/QOpenSys/usr/bin:/usr/ccs/bin:/QOpenSys/usr/bin/X11:/usr/sbin:.:/usr/bin:/QOpenSys/pkgs/bin:$path"
export PATH
SCRIPTNAME=$(basename $0)

function error_exit
{
# ----------------------------------------------------------------
# Function for exit due to fatal program error
# Accepts 1 argument: string containing descriptive error message
# ---------------------------------------------------------------- 

  #echo "//-----------------------------------------------------------"    
  echo "ERROR: ${SCRIPTNAME}: ${1:-"Unknown Error"}" 1>&2
  #echo "//-----------------------------------------------------------"
  exit 1
}

# Make sure our arguments are passed
if [ $# -lt 1 ]
then
  error_exit "ERROR: Missing parameters. Ping script needs [Hostname/IP]. Process cancelled." 
fi

# Get passed parm arguments
HOSTNAME=$1

# Run CL system command and exit with errors on failure.
system -v "PING '$HOSTNAME'" 
if [ $? -ne 0 ]; then
   error_exit "Error running PING CL command. Process cancelled."
fi
