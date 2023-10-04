#!/bin/bash
echo ""
echo "===============================================  The input spreasheet should have the following format:  ================================================"
echo "| CLASS | ADMISSION NO. | STUDENT FIRST NAME | STUDENT LAST NAME | STUDENT EMAIL | HOUSE | TEACHER FIRST NAME | TEACHER LAST NAME | CLASS TEACHER EMAIL |"
echo "========================================================================================================================================================="
echo ""

# Set the FILE equal to the next command argument, i.e., $./SCRIPT.sh FILE.csv
FILE=${1}

# Remove the header from the CSV file, then remove " marks from cells & get rid of windows carrage return.
tail -n +2 "$FILE" | grep -v "Count:" | sed 's/"//g' | sed 's/\r$//' > /tmp/HEADLESS_FILE.csv

# Sort the CSV file by emails for both students and staff.
sort -t, -k5 < /tmp/HEADLESS_FILE.csv | tail -n +2 > /tmp/STUDENT_SORTED_FILE.csv
sort -t, -k9 < /tmp/HEADLESS_FILE.csv| tail -n +2 > /tmp/STAFF_SORTED_FILE.csv

# Set the Field Separator to read line by line
IFS=$'\n'

PRE_EMAIL=""
COMBINED=()
DEDUPED_CLASSES=""
TEACHER="FALSE"

for line in $(cat "/tmp/STUDENT_SORTED_FILE.csv")
do
    # Set Field Separator to a comma and create variables for each column
    IFS=','
    read CLASS ADMISSION FIRST LAST EMAIL HOUSE TFIRST TLAST TEMAIL <<<"${line}"
   USERNAME=$(cut -d@ -f1 <<< "$EMAIL")
    CLASS=\!$CLASS\!
    if [ "$EMAIL" = "$PRE_EMAIL" ]; then
        #If the student is the same, stack the classes togehter
        CLASSES=(${CLASS//,/ })


        for item in "${CLASSES[@]}"; do
            if [[ ! "${COMBINED[@]}" =~ "$CLASS" ]]; then
                COMBINED+=("$CLASS")
            fi
        done

        # Join the new list of strings back into a string, separated by commas.
        DEDUPED_CLASSES=$(IFS=','; echo "${COMBINED[*]}")

    else

        #Export the prevous student to the csv file
       if [ "$PRE_EMAIL" = "" ]; then
            COMBINED+=("$CLASS")
        else
            echo "Outputting $PRE_USERNAME to CSV"
            echo "$PRE_USERNAME,$PRE_EMAIL,$PRE_FIRST,$PRE_LAST,\"$DEDUPED_CLASSES\",," >> /tmp/output.csv
            COMBINED=("$CLASS")
        fi        
    fi

    PRE_EMAIL="$EMAIL"
    PRE_USERNAME="$USERNAME"
    PRE_FIRST="$FIRST"
    PRE_LAST="$LAST"

done
# starting on Teachers

# Set the Field Separator to read line by line
IFS=$'\n'

for line in $(cat "/tmp/STAFF_SORTED_FILE.csv")
do
    # Set Field Separator to a comma and create variables for each column
    IFS=','
    read CLASS ADMISSION SFIRST SLAST EMAIL HOUSE FIRST LAST EMAIL <<<"${line}"
   USERNAME=$(cut -d@ -f1 <<< "$EMAIL")
   
    #Wrap Class to stop forms from not coming through
    CLASS=\!$CLASS\!

    if [ "$EMAIL" = "$PRE_EMAIL" ]; then
        #If the student is the same, stack the classes togehter
        CLASSES=(${CLASS//,/ })


        for item in "${CLASSES[@]}"; do
            if [[ ! "${COMBINED[@]}" =~ "$CLASS" ]]; then
                COMBINED+=("$CLASS")
            fi
        done

        # Join the new list of strings back into a string, separated by commas.
        DEDUPED_CLASSES=$(IFS=','; echo "${COMBINED[*]}")

                       
    else

        #Export the prevous student to the csv file
       if [ "$PRE_EMAIL" = "" ]; then
            COMBINED+=("$CLASS")
        else
            echo "Outputting $PRE_USERNAME to CSV"
            #Check to make sure last student has been entered before switching to Teacher Groups
            if [ "$TEACHER" = "TRUE" ]; then
                echo "$PRE_USERNAME,$PRE_EMAIL,$PRE_FIRST,$PRE_LAST,\"STAFF\",\"$DEDUPED_CLASSES\"," >> /tmp/output.csv
                COMBINED=("$CLASS")
            else
                echo "$PRE_USERNAME,$PRE_EMAIL,$PRE_FIRST,$PRE_LAST,\"$DEDUPED_CLASSES\",," >> /tmp/output.csv
                COMBINED=("$CLASS")
                TEACHER="TRUE"
                echo ""
                echo "================  STARTING TEACHERS  ================"
                echo ""
            fi
        fi        
    fi

    PRE_EMAIL="$EMAIL"
    PRE_USERNAME="$USERNAME"
    PRE_FIRST="$FIRST"
    PRE_LAST="$LAST"

done


#Export the last staff member to the csv file as they are missed by the loop
echo "Outputting $PRE_USERNAME to CSV"
echo "$PRE_USERNAME,$PRE_EMAIL,$PRE_FIRST,$PRE_LAST,\"STAFF",\"$DEDUPED_CLASSES\"," >> /tmp/output.csv


#Put the headers in the output file then copy from the temp output to final file
echo "Username,Email,FirstName,LastName,Groups,TeacherGroups,Password" > ./output.csv

#Export outut and remove ! that was used to wrap the classes
cat /tmp/output.csv | sed 's/!//g' >> ./output.csv

#Cleaning up temp files
rm /tmp/output.csv /tmp/STUDENT_SORTED_FILE.csv /tmp/STAFF_SORTED_FILE.csv /tmp/HEADLESS_FILE.csv

echo ""
echo "===================================================================================================================================================="
echo "=================================================================   completed.  ===================================================================="
echo "===================================================================================================================================================="
echo ""
