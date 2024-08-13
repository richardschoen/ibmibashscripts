#!/QOpenSys/pkgs/bin/bash
#----------------------------------------------------------------
# Script name: untardir.sh
# Author: Richard Schoen
# Parameters:
# 1.) File name to unzip and unarchive with tar. Can also use a partial wildcard.
#     Files and dirs are extracted to the same dir where the .tar.gz file is located.
# 
# Purpose: Extract all files and subdirs from 
#          a .tar.gz file to current directory
#
# Result: 
# All files should be extracted and listed to STDOUT console log as well. 
# Exits:
# 0=Normal - No errors. 
# Non-zero - Errors occuured.
#
# Useful links:
# https://www.linuxquestions.org/questions/linux-newbie-8/tar-all-files-and-folders-in-the-current-directory-4175487694/
# https://superuser.com/questions/418704/7-zip-command-line-to-zip-all-the-content-of-a-folder-without-zipping-the-folde
#---------------------------------------------------------------- 

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
  error_exit "ERROR: Missing parameters. P1-File name must be specified. Process cancelled." 
fi

# Set date/time variables
DATESTAMP=$(date +%Y%m%d)
TIMESTAMP=$(date +%H%M%S)
EPOCHVALUE=$(date "+%s")
EPOCHFIRST10="T${EPOCHVALUE:0:10}"
EPOCHFIRST9="T${EPOCHVALUE:0:9}"
EPOCHFIRST6="T${EPOCHVALUE:0:6}"

# https://www.shell-tips.com/linux/how-to-format-date-and-time-in-linux-macos-and-bash

# Set output file from passed file prefix. 
# Output file will be unique timestamped.
OUTPUTFILE=$1

# Tar and gzip files in selected current directory to tar file.
# Tar file named based on passed in prefix + timestamp.tar.gz
# Use . to archive all files, including hidden ones.
# Note: Could change to * to archive all files, and skip hidden ones.
tar -xvf ${OUTPUTFILE}

echo "Files unarchived from ${OUTPUTFILE}"
