#!/QOpenSys/pkgs/bin/bash
#----------------------------------------------------------------
# Script name: savlibifs.sh
# Purpose: Save an IBM i library to a PC/IFS save file
# Parameters: See the usage() function
#---------------------------------------------------------------- 

#Blow up on any errors
#set -e

PATH="/QOpenSys/usr/bin:/usr/ccs/bin:/QOpenSys/usr/bin/X11:/usr/sbin:.:/usr/bin:/QOpenSys/pkgs/bin:$path"
export PATH

PROGNAME=$(basename $0)

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
Desc: This script saves an IBM i library to a temporary save file and copies to an IFS file

OPTIONS
  -h, --help       Display this help text
  -l, --library    IBM i library                 **required**
  -o, --outputfile IBM output IFS file           **required**
  -r, --replace    Replace IFS file if found     **required**"
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
       LIBRARY=${LIBRARY^^} #convert to uppercase       
       shift # past argument=value
       ;;
    -o=*|--outputfile=*)
       OUTPUTFILE="${opts#*=}"
       shift # past argument=value
       ;;
    -r=*|--replace=*)
       REPLACE="${opts#*=}"
       REPLACE=${REPLACE^^} #convert to uppercase              
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
if [[ -z "$LIBRARY" || -z "$OUTPUTFILE" ||-z "$REPLACE"  ]]; then
    # Output the required parm selected values for reference
    echo "Current parameter values:"
    echo "LIBRARY      = $LIBRARY"
    echo "OUTPUTFILE   = $OUTPUTFILE"
    echo "REPLACE      = $REPLACE"
    ERROR="ERROR: Missing at least one required option"
    REQUIRED="[-l,--library] [-o,--outputfile] [-r,--replace]"
    print_cli_error "$ERROR\nRequired options: $REQUIRED"
fi

# Build work variables
DATESTAMP=$(date +%Y%m%d)
TIMESTAMP=$(date +%H%M%S)
#Build temp save file T + Epoch data last 9 digits
SAVFNAME=$(date +"%s")
SAVFNAME="T${SAVFNAME:1:9}" 
SAVFLIB="TMPOBJ"

# Replace any timestamp in file name templates to build IFS file name
OUTPUTFILE=${OUTPUTFILE/@@DATETIME/$DATESTAMP$TIMESTAMP}
OUTPUTFILE=${OUTPUTFILE/@@DATE/$DATESTAMP}
OUTPUTFILE=${OUTPUTFILE/@@TIME/$TIMESTAMP}

echo "//-----------------------------------------------------------"
echo "//Start Process - Save IBM i Library $LIBRARY to IFS File $OUTPUTFILE - $(date)"
echo "//-----------------------------------------------------------"

# Check for IFSoutput file exists already and bail if replace <> "Y" 
if [ -f "$OUTPUTFILE" ]; then
    if [ $REPLACE == "Y" ]; then
       echo "Deleting existing IFS output file $OUTPUTFILE before processing."
       rm "$OUTPUTFILE" # Remove existing file
       if [ $? -ne 0 ]; then
          error_exit "Error deleting IFS file $OUTPUTFILE. Process cancelled."
       fi
    else
       error_exit "Output IFS file $OUTPUTFILE exists and replace not selected. Process cancelled."
    fi 
else 
    echo "//Output file $OUTPUTFILE does not exist. Process will run."
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
echo "//Copying library $LIBRARY save file to $OUTPUTFILE now..."
echo "//-----------------------------------------------------------"
system -v "CPYTOSTMF FROMMBR('/QSYS.LIB/$SAVFLIB.LIB/$SAVFNAME.FILE') TOSTMF('$OUTPUTFILE') STMFOPT(*REPLACE) CVTDTA(*NONE) STMFCCSID(*STMF)"
if [ $? -ne 0 ]; then
   error_exit "Error running CPYTOSTMF. Process cancelled."
else
    # Check for IFSoutput file exists already and bail if replace <> "Y" 
    if [ ! -f "$OUTPUTFILE" ]; then
        error_exit "Output IFS file $OUTPUTFILE does not exist. Save library to IFS failed."
    else 
       echo "//-----------------------------------------------------------"
       echo "//Output IFS file $OUTPUTFILE exists. Save library to IFS was successful."
       echo "//Completion: Library $LIBRARY was saved to IFS file $OUTPUTFILE"
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
echo "//End Process - Save IBM i Library $LIBRARY to IFS File $OUTPUTFILE - $(date)"
echo "//-----------------------------------------------------------"
