#!/bin/bash

regex=$(tr -d '[:space:]' < "regex for matching multiplication.txt" | sed -e 's/(?#[^)]*)//g')

echo Regex length = $(echo -n "$regex"|wc -c)
echo Regex md5sum = $(echo -n "$regex"|md5sum)
echo

for (( phase=0; phase<=1; phase++ ))
do
	for (( a=2; a<=12; a++ )); do
	for (( b=1; b<=12; b++ )); do
	for (( c=1; c<=144; c++ )); do
		correct=$(($a * $b == $c))
		if [[ $correct -eq $phase ]]; then
			continue
		fi
		result=$( (
			time (perl -E "print 'x' x $a; print '*'; print 'x' x $b; print '='; print 'x' x $c" |
				pcregrep "$regex")
		) 2>&1 )
		grep_result="${result%%
*}"
		time_result="${result#*
}"
		time_result="${time_result%%
*}"
		if [ -n "${grep_result}" ]; then
			echo -n $time_result: $a \* $b = $c
			[[ $correct -ne 0 ]] && echo "" || echo " - FALSE POSITIVE!"
		elif [[ $correct -ne 0 ]]; then
			echo $time_result: $a \* $b != $c " - FALSE NEGATIVE!"
		fi
	done
	done
	done
done
