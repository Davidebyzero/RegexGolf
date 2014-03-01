#!/bin/bash

regex=$(tr -d '[:space:]' < "regex for matching multiplication.txt")

echo Regex length = $(echo -n "$regex"|wc -c)

for (( a=1; a<=12; a++ )); do
for (( b=1; b<=12; b++ )); do
for (( c=1; c<=144; c++ )); do
	result=$( (
		time (perl -E "print 'x' x $a; print '*'; print 'x' x $b; print '='; print 'x' x $c" |
			pgrep "$regex")
	) 2>&1 )
	grep_result="${result%%
*}"
	time_result="${result#*
}"
	time_result="${time_result%%
*}"
	correct=$(($a * $b == $c))
	if [ -n "${grep_result}" ]; then
		echo -n $time_result: $a \* $b = $c
		[[ $correct -ne 0 ]] && echo "" || echo " - FALSE POSITIVE!"
	elif [[ $correct -ne 0 ]]; then
		echo $time_result: $a \* $b != $c " - FALSE NEGATIVE!"
	fi
done
done
done
