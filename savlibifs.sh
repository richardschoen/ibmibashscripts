#!/QOpenSys/pkgs/bin/bash
#----------------------------------------------------------------
# Script name: savlibifs.sh
# Purpose: Save an IBM i library to a PC/IFS save file
# Parameters:
# 1.) LibraryName to save
# 2.) TO IFS file containing save file data
# 3.) Replace IFS file if found. N-No Y-Yes
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
if [ $# -lt 3 ]
then
  error_exit "Missing parameters. Script needs [LibraryNameToSave] [OutputToIFSFile] [Replace-Y/N]. Process cancelled." 
fi

# Get passed parm arguments
LIBRARY=$1
TOIFSFILE=$2
REPLACEFILE=$3
DATESTAMP=$(date +%Y%m%d)
TIMESTAMP=$(date +%H%M%S)
#Build temp save file T + Epoch data last 9 digits
SAVFNAME=$(date +"%s")
SAVFNAME="T${SAVFNAME:1:9}" 
SAVFLIB="TMP"

# Replace any timestamp in file name templates to build IFS file name
TOIFSFILE=${TOIFSFILE/@@DATETIME/$DATESTAMP$TIMESTAMP}
TOIFSFILE=${TOIFSFILE/@@DATE/$DATESTAMP}
TOIFSFILE=${TOIFSFILE/@@TIME/$TIMESTAMP}

echo "//-----------------------------------------------------------"
echo "//Start Process - Save IBM i Library $LIBRARY to IFS File $TOIFSFILE - $(date)"
echo "//-----------------------------------------------------------"

# Check for IFSoutput file exists already and bail if replace <> "Y" 
if [ -f "$TOIFSFILE" ]; then
    if [ $REPLACEFILE == "Y" ]; then
       rm "$TOIFSFILE" # Remove existing file
       if [ $? -ne 0 ]; then
          error_exit "Error deleting IFS file $TOIFSFILE. Process cancelled."
       fi
    else
       error_exit "Output IFS file $TOIFSFILE exists and replace not selected. Process cancelled."
    fi 
else 
    echo "//Output file $TOIFSFILE does not exist. Process will run."
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
 
# Save selected library now and copy save file object to IFS file
echo "//-----------------------------------------------------------"
echo "//Saving library $LIBRARY to save $SAVFLIB/$SAVFNAME file now..."
echo "//-----------------------------------------------------------"
system -v "SAVLIB LIB($LIBRARY) DEV(*SAVF) SAVF($SAVFLIB/$SAVFNAME) TGTRLS(*CURRENT) UPDHST(*YES) PRECHK(*YES) SAVACT(*NO) SPLFDTA(*ALL) QDTA(*DTAQ) DTACPR(*HIGH)"    
if [ $? -ne 0 ]; then
   error_exit "Error running SAVLIB. Process cancelled."
fi

echo "//-----------------------------------------------------------"
echo "//Copying library $LIBRARY save file to $TOIFSFILE now..."
echo "//-----------------------------------------------------------"
system -v "CPYTOSTMF FROMMBR('/QSYS.LIB/$SAVFLIB.LIB/$SAVFNAME.FILE') TOSTMF('$TOIFSFILE') STMFOPT(*REPLACE) CVTDTA(*NONE) STMFCCSID(*STMF)"
if [ $? -ne 0 ]; then
   error_exit "Error running CPYTOSTMF. Process cancelled."
else
    # Check for IFSoutput file exists already and bail if replace <> "Y" 
    if [ ! -f "$TOIFSFILE" ]; then
        error_exit "Output IFS file $TOIFSFILE does not exist. Save library to IFS failed."
    else 
       echo "//-----------------------------------------------------------"
       echo "//Output IFS file $TOIFSFILE exists. Save library to IFS was successful."
       echo "//Completion: Library $LIBRARY was saved to IFS file $TOIFSFILE"
       echo "//-----------------------------------------------------------"
    fi   
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
echo "//End Process - Save IBM i Library $LIBRARY to IFS File $TOIFSFILE - $(date)"
echo "//-----------------------------------------------------------"
