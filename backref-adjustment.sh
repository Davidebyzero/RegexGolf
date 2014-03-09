#!/bin/bash

if [ -z "$3" ] || [ "$3" -eq 0 ] || [ "$1" -gt "$2" ]; then
    echo -n "\
\
Usage: $0 FIRST LAST INC [FILE]
Add INC to the index of all regex backreferences from FIRST to LAST inclusive.
Example: $0 3 15 -1 < INPUTFILE > OUTPUTFILE
         This changes all backreferences in INPUTFILE from \3 to \15 to go from
         \2 to \14 instead, and writes the result to OUTPUTFILE.
Example: $0 5 23 3 regex.txt
         This changes all backreferences in "regex.txt" from \5 to \23 to go from
         '\8 to \26 instead, and overwrites the file "regex.txt" with the result.
"
    exit
fi

script=$(
    if [ $3 -ge 0 ]; then
        for (( i=$2; i>=$1; i-- )); do
            echo 's/\\'$i'(?!\d)/\\'$(($i+$3))'/g;'
        done
    else
        for (( i=$1; i<=$2; i++ )); do
            echo 's/\\'$i'(?!\d)/\\'$(($i+$3))'/g;'
        done
    fi
    echo -n 'print'
)

if [ -z "$4" ]; then
    perl -ne"$script"
else
    if [ -f "$4" ]; then
        input=$(cat "$4")
        if [ "$?" -eq 0 ]; then
            echo -n "$input" | perl -ne"$script" > "$4"
        else
            echo "Error read file $4"
        fi
    else
        echo "Error opening file $4"
    fi
fi
