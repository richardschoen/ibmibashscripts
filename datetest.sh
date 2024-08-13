# This is an example of formatting dates and times for a script
# https://www.shell-tips.com/linux/how-to-format-date-and-time-in-linux-macos-and-bash

# Set date/time variables
DATESTAMP=$(date +%Y%m%d)
TIMESTAMP=$(date +%H%M%S)
EPOCHVALUE=$(date "+%s")
EPOCHFIRST10="T${EPOCHVALUE:0:10}"
EPOCHFIRST9="T${EPOCHVALUE:0:9}"
EPOCHFIRST6="T${EPOCHVALUE:0:6}"

# Output variable values
echo "Date:${DATESTAMP}\n"
echo "Time:${TIMESTAMP}\n"
echo "Epochseconds:${EPOCHVALUE}\n"
echo "Epoch first 6:${EPOCHFIRST6}\n"
echo "Epoch first 9:${EPOCHFIRST9}\n"
echo "Epoch first 10:${EPOCHFIRST10}\n"

