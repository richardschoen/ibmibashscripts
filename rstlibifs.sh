#!/QOpenSys/pkgs/bin/bash
#----------------------------------------------------------------
# Script name: rstlibifs.sh
# Purpose: Restore an IBM i library from a PC/IFS save file
# Parameters:
# 1.) LibraryName to restore
# 2.) From IFS file containing save file data
# 3.) Restore to library. Specify alternate library name if desired or 
#     *SAME or *SAVLIB will restore to existing library.
#---------------------------------------------------------------- 

#Blow up on any errors
#set -e

PATH="/QOpenSys/usr/bin:/usr/ccs/bin:/QOpenSys/usr/bin/X11:/usr/sbin:.:/usr/bin:/QOpenSys/pkgs/bin:$path"
export PATH
PROGNAME=$(basename $0)

function error_exit
{
#   ----------------------------------------------------------------
#   Function for exit due to fatal program error
#       Accepts 1 argument:
#           string containing descriptive error message
#   ---------------------------------------------------------------- 

    echo "//-----------------------------------------------------------"    
    echo "//${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
    echo "//-----------------------------------------------------------"
    exit 1
}

# Make sure our arguments are passed
if [ $# -lt 2 ]
then
  error_exit "Missing parameters. Script needs [LibraryNameToRestore] [FromIFSFile] [Optional-RestoreToLibrary-*SAME]. Process cancelled." 
fi

# Get passed parm arguments
LIBRARY=${1^^} #convert lib to uppercase
TOLIBRARY="*SAVLIB"

# If TOLIBRARY value passed, set TOLIBRARY. 
# Otherwise we will use default value in TOLIBRARY
if [ -n "$3" ]; then
    TOLIBRARY=${3^^}
    # Set to saved library as dest resotore library if parm passed as *SAME 
    if [ "$3" == "*SAME" ]; then
       TOLIBRARY=$LIBRARY
    fi
fi

FROMIFSFILE=$2
DATESTAMP=$(date +%Y%m%d)
TIMESTAMP=$(date +%H%M%S)
#Build temp save file T + Epoch data last 9 digits
SAVFNAME=$(date +"%s")
SAVFNAME="T${SAVFNAME:1:9}" 
SAVFLIB="TMP"

# Replace any timestamp in file name templates to build IFS file name
FROMIFSFILE=${FROMIFSFILE/@@DATETIME/$DATESTAMP$TIMESTAMP}
FROMIFSFILE=${FROMIFSFILE/@@DATE/$DATESTAMP}
FROMIFSFILE=${FROMIFSFILE/@@TIME/$TIMESTAMP}

echo "//-----------------------------------------------------------"
echo "//Start Process - Restore IBM i Library $LIBRARY from IFS File $FROMIFSFILE to library $TOLIBRARY - $(date)"
echo "//-----------------------------------------------------------"

# Check for IFS input file exists. Bail if IFS file not found. 
if [ ! -f "$FROMIFSFILE" ]; then
       error_exit "Input save file IFS file $FROMIFSFILE does not exist. Process cancelled."
fi

# Make sure TMP library exists and also create temporary backup save file
echo "//-----------------------------------------------------------"
echo "//Creating temporary objects for library save"
echo "//-----------------------------------------------------------"
system -v "CRTLIB LIB($SAVFLIB) TEXT('Temp Object Library')"  
system -v "CRTSAVF FILE($SAVFLIB/$SAVFNAME) TEXT('Temp Library Save File')"
system -v "CLRSAVF FILE($SAVFLIB/$SAVFNAME)"
if [ $? -ne 0 ]; then
   error_exit "Error clearing save file. Process cancelled."
fi

echo "//-----------------------------------------------------------"
echo "//Copying save file data for $LIBRARY from $FROMIFSFILE to temp save file $SAVFLIB/$SAVFFILE now..."
echo "//-----------------------------------------------------------"
system -v "CPYFRMSTMF TOMBR('/QSYS.LIB/$SAVFLIB.LIB/$SAVFNAME.FILE') FROMSTMF('$FROMIFSFILE') MBROPT(*REPLACE) CVTDTA(*NONE)"
if [ $? -ne 0 ]; then
   error_exit "Error running CPYFRMSTMF. Process cancelled."
fi
 
# Save selected library now and copy save file object to IFS file
echo "//-----------------------------------------------------------"
echo "//Restore library $LIBRARY from save file $SAVFLIB/$SAVFNAME now..."
echo "//-----------------------------------------------------------"
system -v "RSTLIB SAVLIB($LIBRARY) DEV(*SAVF) SAVF($SAVFLIB/$SAVFNAME) OPTION(*ALL) MBROPT(*ALL) ALWOBJDIF(*ALL) RSTLIB($TOLIBRARY)"
if [ $? -ne 0 ]; then
   error_exit "Error running RSTLIB. Check the save file contents on the IBM i via the following command: DSPSAVF FILE($SAVFLIB/$SAVFNAME). Process cancelled."
else
       echo "//-----------------------------------------------------------"
       echo "//Completion: Library $LIBRARY was restored successfully from IFS file $FROMIFSFILE to library $TOLIBRARY"
       echo "//-----------------------------------------------------------"
fi

# Clean up the temp save file after we're done
echo "//-----------------------------------------------------------"
echo "//Removing temp save file $SAVFLIB/$SAVFNAME now..."
echo "//-----------------------------------------------------------"
system -v "DLTF FILE($SAVFLIB/$SAVFNAME)"    
if [ $? -ne 0 ]; then
   error_exit "Error deleting save file. Process cancelled."
fi

echo "//-----------------------------------------------------------"
echo "//End Process - Restore IBM i Library $LIBRARY from IFS File $FROMIFSFILE to library $TOLIBRARY - $(date)"
echo "//-----------------------------------------------------------"
