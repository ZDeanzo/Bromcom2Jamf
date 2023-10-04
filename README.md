# Bromcom2Jamf
Bash script to convert a Bromcom class report CSV into corretly formatted CSVs for import into JAMF school.

To use the script call it in a MacOS/Linux terminal and enter the location of the Bromcom export. i.e. ./convert.sh ./BromcomExport.csv

The Bromcom exported spreasheet is expected to have the following format:
| CLASS | ADMISSION NO. | STUDENT FIRST NAME | STUDENT LAST NAME | STUDENT EMAIL | HOUSE | TEACHER FIRST NAME | TEACHER LAST NAME | CLASS TEACHER EMAIL |

ADMISSION NO. & HOUSE are not used in the script but their columns are anticipted by the code. The script will cycle first though the students, then staff and gather up all of thier classes before outputting a csv file with the correct formatting for JAMF school. The staff are added to the class groups as teachers and are also added to a "STAFF" user group.
