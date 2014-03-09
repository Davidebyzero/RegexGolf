#!/bin/bash

if [ -z "$3" ] || [ "$3" -eq 0 ] || [ "$1" -gt "$2" ]; then
    echo "Usage: $0 FIRST LAST INC"
    echo "Adjust all regex backreferences starting with FIRST and ending with LAST by INC."
    echo "Example: $0 3 15 -1 < INPUTFILE > OUTPUTFILE"
    echo '         This changes all backreferences from \3 to \15 to go from \2 to \14 instead.'
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
perl -ne"$script"
