#!/bin/bash

# Script for convert from Filezilla xml config file to mc hotlist config file
# Version: 1.0
# Author: Stanislav Hosek, 2019

infile="filezilla.xml"
base64="/usr/bin/base64"
outfile="converted.txt"

echo "---------------------------------------------------------------"
echo "| Filezilla xml config file convert to mc hotlist config file |"
echo "---------------------------------------------------------------"
echo "Directory: `pwd`"
echo "Input file: $infile"
echo "Output file: $outfile"

# Check if file exists
if [ ! -f $base64 ]; then
echo "ERR: Binary file $base64 does not exists! Install it."
exit 1

# Check if file exists
elif [ ! -f $infile ]; then
echo "ERR: No $infile found in root directory! Copy $infile to directory `pwd`."
exit 1

# Check if directory is writable
elif [ ! -w `pwd` ]; then echo "ERR: Directory is not writable! Change the rights to writable for this directory."
exit 1

else

# Grep needed information
host="$(cat $infile | grep -e Host | sed -e 's/<Host>\(.*\)<\/Host>/\1/' | sed -e 's/^[ \t]*//' > host)"
pass="$(cat $infile | grep -e Pass | sed -e 's/<Pass encoding="base64">\(.*\)<\/Pass>/\1/' | sed -e 's/^[ \t]*//' > passbase64)"
port="$(cat $infile | grep -e Port | sed -e 's/<Port>\(.*\)<\/Port>/\1/' | sed -e 's/^[ \t]*//' > port)"
user="$(cat $infile | grep -e User | sed -e 's/<User>\(.*\)<\/User>/\1/' | sed -e 's/^[ \t]*//' > user)"

# base64 decode pass temp file
while IFS= read -r line; do echo $line | base64 -d; echo ""; done < passbase64 > pass

# Paste variables to columns (not working)
#~ paste <(printf %s "$port") <(printf %s "$host") <(printf %s "$user") <(printf %s "$pass") > temp

# Paste temp files to columns
paste -d ' ' port host user pass > temp

# Add strings to variables based on ports
while read -r column1 column2 column3 column4; do
if [[ $column1 == "21" ]] ; then
echo "ENTRY \"$column2\" URL \"ftp://$column3:$column4@$column2:/\"" 
elif [[ $column1 == "22" ]]; then
echo "ENTRY \"$column2\" URL \"/sftp://$column3:$column4@$column2:/\"" 
fi
done < temp > $outfile

echo "Finished, saved to $outfile file."

# Removing temp files
rm -rf host passbase64 port user pass temp

fi
