#!/bin/bash

# Set the FILE equal to the next command argument, i.e., $./SCRIPT.sh FILE.csv
FILE=${1}

# Set the Field Separator to read line by line
IFS=$'\n'

PRE_EMAIL=""
COMBINED=""
NEWFILE=Converted.csv

for line in $(cat "${FILE}")
do
    # Set Field Separator to a comma and create variables for each column
    IFS=','
    read CLASS ADMISSION FIRST LAST EMAIL HOUSE TEACHER <<<"${line}"

   

    if [ "$EMAIL" = "$PRE_EMAIL" ]; then
        #If the student is the same, stack the classes togehter
        if [ "$COMBINED" = "" ]; then
            COMBINED="$CLASS"
        else
            COMBINED="$CLASS,$COMBINED"
        fi
       
    else
        #Export the prevous student to the csv file
        echo "Outputting $PRE_USERNAME,$PRE_EMAIL,$PRE_FIRST,$PRE_LAST,\"$COMBINED\",, to CSV"
        echo "$PRE_USERNAME,$PRE_EMAIL,$PRE_FIRST,$PRE_LAST,\"$COMBINED\",," >> output.csv
        COMBINED=""
        
    fi

    PRE_EMAIL="$EMAIL"
    PRE_USERNAME="$EMAIL"
    PRE_FIRST="$FIRST"
    PRE_LAST="$LAST"

done

#Export the last student to the csv file as they are missed by the loop
echo "Outputting $PRE_USERNAME,$PRE_EMAIL,$PRE_FIRST,$PRE_LAST,\"$COMBINED\",, to CSV"
echo "$PRE_USERNAME,$PRE_EMAIL,$PRE_FIRST,$PRE_LAST,\"$COMBINED\",," >> output.csv
