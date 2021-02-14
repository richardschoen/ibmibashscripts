#!/QOpenSys/pkgs/bin/bash
#----------------------------------------------------------------
# Script name: cpysrctoifs.sh
# Author: Richard Schoen
# Parameters:
# 1.) Desired source member name plus source type extension. Ex: SAMPLE.CLP
#     (You don't need to specify a directory path because it uses current dir)
# 2.) Replace IFS file. N-DO not replace IFS file member, Y-Replace IFS file.
#     (This parm is optional and defaults to Y if not passed.)     
# 
# Purpose: Copy an IBM i library based source member to a corresponding
# IFS work folder based on name only so the file can be edited from the
# IFS directly and then optionally returned to the source member using 
# mbr
#
# IFS directory path must correspond to an actual library/file/member structure.
# Ex source library file: Lib:QGPL File:QCLSRC Member:SAMPLE Type:CLP 
# Ex IFS dir to receive the member for editing: /gitrepos/QGPL/QCLSRC/SAMPLE.CLP
# Ex usage of the ifstombr.sh command:
# Open a bash or other SSH session and change to working directory
# to receive the source member from the library. In this example I am using
# a Git repository path, but you don't have to be using Git in order to user
# this command.
#
# Demo sequence to copy source file member SAMPLE.CLP from QGPL/QCLSRC to IFS
# cd /gitrepos/QGPL/QCLSRC
# srcmbrtoifs.sh SAMPLE.CLP
#
# Result: 
# Source member will be copied from selected library to the IFS folder.
# IFS member will be replaced by default unless you specify NO for replace option
# 
# The beauty of this example is that you can work in Visual Studio Code, Notepad++
# RDI or any editor to edit from the IFS using the SSHFS plugin and you can keep 
# a bash/ssh terminal open to quickly copy a current member from your source library 
# into the IFS for working with. 
#
# Exits:
# 0=Normal - No errors. Source member copy to IFS file was successful
# Non-zero - Errors occuured.
#
# Useful links:
# https://www.linuxquestions.org/questions/programming-9/bash-scripting-parsing-a-directory-path-746726/
# https://ryanstutorials.net/bash-scripting-tutorial/bash-if-statements.php
#---------------------------------------------------------------- 

# Top level variable declarations
scriptname=$(basename $0)
dashes="----------------------------------------------------------------------"
verbose="N"

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

echo "${dashes}"
echo "Copy Source Member to IFS - $scriptname"
echo

# Make sure our arguments are passed
if [ $# -lt 1 ]
then
  error_exit "ERROR: Missing parameters. P1-IFS output file name without dir path needed [Ex:SAMPLE.CLP] P2 (Optional)-Replace IFS [Y/N] Dft:Y. Process cancelled." 
fi

# Set top level IFS file name info from current directory
fullifsfilepath="${PWD}/$1"   # Full IFS file work path  
topdir="${PWD}/$1"            # Fule IFS file temp work path
name="$(dirname "$topdir")"

# Get passed parm arguments
pcfilename=$1
replace=$2

# Default replace = "Y" if not passed
if [ "${replace}" = "" ]; then
   replace="Y"
fi

# Iterate the IFS file path name and 
# parse the path into individual elements
while [ "$topdir" != "/" ];do
  i=$(($i+1))
  parse[$i]="$(basename "$topdir")"
  name="$topdir"
  topdir="$(dirname "$topdir")"
  [ "$topdir" = "." ] && topdir="$(pwd -P)"
done

# Extract useful path values. Passed in filename path parameters are parsed in reverse order.
srcpcfile="${parse[1]}" # Extract the PC file name (pass file name only)
srcfile="${parse[2]^^}"   # Extract source file name from current directory path
srclib="${parse[3]^^}"    # Extract source library name from current directory path 
srcmember=`echo "${srcpcfile^^}" | cut -d'.' -f1`  # Parse PC file name prefix to member name
srctype=`echo "${srcpcfile^^}" | cut -d'.' -f2`    # Parse PC file name extenstion to souce type
fullsrcfilepath="/QSYS.LIB/$srclib.LIB/$srcfile.FILE/$srcmember.MBR"

# Check for IBM i source member existence. Bail out if source member does not exist.
if [ -f "$fullsrcfilepath" ]; then
    echo "Source member: $srclib/$srcfile($srcmember) exists."
else 
    error_exit "ERROR: Source member: $srclib/$srcfile($srcmember) does not exist. Process cancelled."
fi

# Check for PC file existence before transferring.
# We will also check to see if we are OK replacing the IFS member
if [ -f "$fullifsfilepath" ]; then
    echo "IFS file: $fullifsfilepath exists."
    # Bail out if IFS output file exists and replace <> 'Y'
    if [ "${replace^^}" != "Y" ]; then
       error_exit "Output file $fullifsfilepath exists and parm 2-replace <> Y(es) to replace IFS. Process cancelled." 
    fi       
else 
    echo "IFS file: $fullifsfilepath does not exist."
fi

# Display source member values to command line user
if [ $verbose == "Y" ]; then
  echo   
  echo "Full from IFS file path:"
  echo "${fullifsfilepath}"
  echo "Full source member to library path:"
  echo "${fullsrcfilepath}"
  #echo "Topdir:${topdir}"
  echo "Source PC File: ${srcpcfile}"
  echo "Source Library: ${srclib}"
  echo "Source File: ${srcfile}"
  echo "Source Member: ${srcmember}"
  echo "Source Type: ${srctype}"
  echo "Replace IFS file: ${replace}"
  echo
else
  echo
  echo "START: Copying Source member $srclib/$srcfile($srcmember) to $fullifsfilepath"
  echo
fi

# Copy source member from IBM i library to IFS path
system -v "CPYTOSTMF FROMMBR('$fullsrcfilepath') TOSTMF('$fullifsfilepath') STMFOPT(*REPLACE) CVTDTA(*AUTO) DBFCCSID(*FILE) STMFCCSID(*STMF) ENDLINFMT(*CRLF) AUT(*DFT) STMFCODPAG(*STMF)"
if [ $? -ne 0 ]; then
   error_exit "Error running CPYTOSTMF CL command. Process cancelled."
fi
echo
echo "SUCCESS: Source member $srclib/$srcfile($srcmember) was copied to $fullifsfilepath"
echo "${dashes}"
