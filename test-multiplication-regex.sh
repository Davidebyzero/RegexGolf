#!/bin/bash

regex=$(tr -d '[:space:]' < "regex for matching multiplication.txt")

for (( a=1; a<=12; a++ )); do
for (( b=1; b<=12; b++ )); do
for (( c=1; c<=144; c++ )); do
	result=$(
		perl -E "print 'x' x $a; print '*'; print 'x' x $b; print '='; print 'x' x $c" |
			pgrep "$regex"
	)
	if [ -n "$result" ]; then
		echo $a \* $b = $c
	fi
done
done
done
