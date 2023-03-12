#!/QOpenSys/pkgs/bin/bash       
# Script - killprocess.sh                                                                          
# Desc - Kill selected process based on passed process ID file.
# P1 - Process ID file  Ex: /tmp/process1.pid

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
  error_exit "ERROR: Missing parameters. P1-IFS process ID file. Process cancelled."  
fi                                                                                    
# Kill the process listed in the process id file                                                                                      
kill `cat $1`                                                                         
