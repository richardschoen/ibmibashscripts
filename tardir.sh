#!/QOpenSys/pkgs/bin/bash
#----------------------------------------------------------------
# Script name: tardir.sh
# Author: Richard Schoen
# Parameters:
# 1.) Top level directory path to archive
#     Ex: /mydir - All files and dirs under /mydir
#         /mydir/level1 - All files under /mydir/level1
#
# 2.) File directory and file prefix to archive and zip to a .tar.gz file
#     Rest of file is build based on a unique timestamp.
#     Ex command sequence to change to dir and archive contents: 
#     cd /mydir  
#     tardir.sh /tmp/mydir
#     Archives to unique file name based on prefix + current time. 
#     Automatic output file name: /tmp/mydir-yyyyMMdd-hhmmss.tar.gz  
#
# Purpose: Archive all files and subdirs from 
#          a directory and subdirectories to a .tar.gz file 
#          based on the passed in dir/file prefix.
#
# Result: 
# All files should be archived to the .tar.gx file and listed to STDOUT console log as well. 
# Archived files in the .tar.gz file can be viewed with any .tar.gz viewer. 
# On IBM i the .tar.gz files can be viewed with Midnite Commander
#
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
if [ $# -lt 2 ]
then
  error_exit "ERROR: Missing parameters. P1=Directory to archive, P2-Zip file prefix. .tar.gz gets appended autoamtically. Process cancelled." 
fi

# Set date/time variables
OPENSOURCEPATH="/QOpenSys/pkgs/bin"
DATESTAMP=$(date +%Y%m%d)
TIMESTAMP=$(date +%H%M%S)
EPOCHVALUE=$(date "+%s")
EPOCHFIRST10="T${EPOCHVALUE:0:10}"
EPOCHFIRST9="T${EPOCHVALUE:0:9}"
EPOCHFIRST6="T${EPOCHVALUE:0:6}"

# https://www.shell-tips.com/linux/how-to-format-date-and-time-in-linux-macos-and-bash

# Set output file from passed file prefix. 
# Output file will be unique timestamped.
# Ex: /tmp/mydir passed in as prefix will become file: 
#     /tmp/mydir-yyyyMMdd-hhmmss.tar.gz
INPUTPATH=$1
OUTPUTFILE=$2-${DATESTAMP}-${TIMESTAMP}.tar.gz

# Tar and gzip files in selected current directory to tar file.
# Tar file named based on passed in prefix + timestamp.tar.gz
# Use . to archive all files, including hidden ones.
# Note: Could change to * to archive all files, and skip hidden ones.
${OPENSOURCEPATH}/tar -czvf ${OUTPUTFILE} -C ${INPUTPATH} .

echo "All files archived to ${OUTPUTFILE} from ${INPUTPATH}"
