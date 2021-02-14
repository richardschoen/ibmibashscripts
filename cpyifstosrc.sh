#!/QOpenSys/pkgs/bin/bash
#----------------------------------------------------------------
# Script name: cpyifstosrc.sh
# Author: Richard Schoen
# Parameters:
# 1.) Desired source member name plus source type extension. Ex: SAMPLE.CLP
#     (You don't need to specify a directory path because it uses current dir)
# 2.) Replace library source member. N-DO not replace source member, Y-Replace member.
#     (This parm is optional and defaults to Y if not passed.)     
# 
# Purpose: Copy an IFS based source member to a corresponding IBM i library 
# based source member based on the IFS path, file name and extension.
#
# Last 3 elements of IFS directory path must correspond to an actual /library/file/member.type structure.
# Ex IFS file to copy source member from: /gitrepos/QGPL/QCLSRC/SAMPLE.CLP
# Ex source library file: Lib:QGPL File:QCLSRC Member:SAMPLE Type:CLP 
# Ex usage of the ifstombr.sh command:
# Open a bash or other SSH session and change to working directory
# to receive the source member from the library. In this example I am using
# a Git repository path, but you don't have to be using Git in order to user
# this command.
#
# Demo sequence to copy IFS source file member SAMPLE.CLP to library source member QGPL/QCLSRC(SAMPLE)
# cd /gitrepos/QGPL/QCLSRC
# cpyifstosrc.sh SAMPLE.CLP
#
# Result: 
# Source member will be copied from IFS folder to selected library.
# Library source member will be replaced by default unless you specify NO for replace option
# 
# The beauty of this example is that you can work in Visual Studio Code, Notepad++
# RDI or any editor to edit from the IFS using the SSHFS plugin and you can keep 
# a bash/ssh terminal open to quickly copy a current member from the IFS to your source library 
# for compiling. 
#
# Exits:
# 0=Normal - No errors. IFS file copy to source member was successful
# Non-zero - Errors occuured.
#
# Useful links:
# https://www.linuxquestions.org/questions/programming-9/bash-scripting-parsing-a-directory-path-746726/
# https://ryanstutorials.net/bash-scripting-tutorial/bash-if-statements.php
#---------------------------------------------------------------- 

# Top level variable declarations
scriptname=$(basename $0)
dashes="----------------------------------------------------------------------"
cmdaddpfm=""
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
echo "Copy IFS file to Source Member - $scriptname"
echo

# Make sure our arguments are passed
if [ $# -lt 1 ]
then
  error_exit "ERROR: Missing parameters. P1-IFS input file name without dir path needed [Ex:SAMPLE.CLP] P2 (Optional)-Replace Source Member [Y/N] Dft:Y. Process cancelled." 
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

# Check for IFS file existence. Bail out if IFS file does not exist.
if [ -f "$fullifsfilepath" ]; then
    echo "IFS file: $fullifsfilepath exists."
else 
    error_exit "ERROR: IFS source file: $fullifsfilepath does not exist. Process cancelled."
fi

# Check for IBM i source member existence before transferring.
# We will also check to see if we are OK replacing the librarysource member member
if [ -f "$fullsrcfilepath" ]; then
    echo "Source member: $srclib/$srcfile($srcmember) exists."
    # Bail out if IFS output file exists and replace <> 'Y'
    if [ "${replace^^}" != "Y" ]; then
       error_exit "Source member: $srclib/$srcfile($srcmember) exists and parm 2-replace <> Y(es) to replace source member. Process cancelled." 
    fi       
else 
    echo "Source member: $srclib/$srcfile($srcmember) does not exist."
    echo
    # Create new empty source member with selected source type
    if [ $srctype != "" ]; then 
       # Source type not blank 
       cmdaddpfm="ADDPFM FILE($srclib/$srcfile) MBR($srcmember) SRCTYPE($srctype)"          
    else 
        # Source type is blank
       cmdaddpfm="ADDPFM FILE($srclib/$srcfile) MBR($srcmember)"          
    fi
    
    # Run the ADDPFM command to create new source member now
    system -v "$cmdaddpfm"   
    if [ $? -ne 0 ]; then
      error_exit "Error running ADDPFM CL command. Process cancelled."
    fi
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
  echo "START: Copying IFS file $fullifsfilepath to source member $srclib/$srcfile($srcmember)"
  echo
fi

# Copy source member from IFS path to IBM i library
system -v "CPYFRMSTMF FROMSTMF('$fullifsfilepath') TOMBR('$fullsrcfilepath') MBROPT(*REPLACE) CVTDTA(*AUTO) STMFCCSID(*STMF) DBFCCSID(*FILE) ENDLINFMT(*ALL) TABEXPN(*YES) STMFCODPAG(*STMF)"           

if [ $? -ne 0 ]; then
   error_exit "Error running CPYFRMSTMF CL command. Process cancelled."
fi
echo
echo "SUCCESS: IFS file $fullifsfilepath was copied to source member $srclib/$srcfile($srcmember)"
echo "${dashes}"
