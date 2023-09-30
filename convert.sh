#!/bin/bash
echo ""
echo "=============  The input spreasheet should have the following format:  ============="
echo "CLASS | ADMISSION NO. | FIRST NAME | LAST NAME | EMAIL | HOUSE | CLASS TEACHER EMAIL"
echo "===================================================================================="
echo ""

# Set the FILE equal to the next command argument, i.e., $./SCRIPT.sh FILE.csv
FILE=${1}

# Remove the header from the CSV file.
tail -n +2 "$FILE" > /tmp/HEADLESS_FILE.csv

# Sort the CSV file by email.
sort -t, -k5 < /tmp/HEADLESS_FILE.csv > /tmp/SORTED_FILE.csv

# Set the Field Separator to read line by line
IFS=$'\n'

PRE_EMAIL=""
COMBINED=""
NEWFILE=Converted.csv

for line in $(cat "/tmp/SORTED_FILE.csv")
do
    # Set Field Separator to a comma and create variables for each column
    IFS=','
    read CLASS ADMISSION FIRST LAST EMAIL HOUSE TEACHER <<<"${line}"
   USERNAME=$(cut -d@ -f1 <<< "$EMAIL")

    if [ "$EMAIL" = "$PRE_EMAIL" ]; then
        #If the student is the same, stack the classes togehter
        if [ "$COMBINED" = "" ]; then
            COMBINED="$CLASS"
        else
            COMBINED="$CLASS,$COMBINED"
        fi     
    else
        #Export the prevous student to the csv file
       if [ "$PRE_EMAIL" = "" ]; then
            COMBINED="$CLASS"
        else
            echo "Outputting $PRE_USERNAME to CSV"
            echo "$PRE_USERNAME,$PRE_EMAIL,$PRE_FIRST,$PRE_LAST,\"$COMBINED\",," >> /tmp/output.csv
            COMBINED="$CLASS"
        fi        
    fi

    PRE_EMAIL="$EMAIL"
    PRE_USERNAME="$USERNAME"
    PRE_FIRST="$FIRST"
    PRE_LAST="$LAST"

done

#Export the last student to the csv file as they are missed by the loop
echo "Outputting $PRE_USERNAME to CSV"
echo "$PRE_USERNAME,$PRE_EMAIL,$PRE_FIRST,$PRE_LAST,\"$COMBINED\",," >> /tmp/output.csv

#Put the headers in the output file then copy from the temp output to final file
echo "Username,Email,FirstName,LastName,Groups,TeacherGroups,Password" > ./output.csv
cat /tmp/output.csv >> ./output.csv

#Cleaning up temp files
rm /tmp/output.csv /tmp/SORTED_FILE.csv /tmp/HEADLESS_FILE.csv

echo ""
echo "===================================================================================="
echo "================================  Task completed.  ================================="
echo "===================================================================================="
echo ""
