#!/bin/bash

if [ -z "$2" ]; then
	echo "Usage: $0 N FILE"
	echo "Reads a regex matching N-gonal numbers from FILE and tests it."
	exit
fi

if [ "$1" -lt 2 ]; then
	echo "Usage: $0 N FILE"
    echo "Error: N must be >=2"
    exit
fi

regex=$(tr -d '[:space:]' < "$2" | sed -e 's/(?#[^)]*)//g')

echo Regex length = $(echo -n "$regex"|wc -c)
echo Regex md5sum = $(echo -n "$regex"|md5sum)
echo

c=$(($1 - 2))

echo -n "$regex" |
perl -E '
	$regex = <>;
	$n = 0;
	$z = 1;
	foreach my $a (0..2025)  {
		$match = ("x" x ($a)) =~ /$regex/;
		if ($a == $n) {
			if ($match) {
				say $a
			} else {
				say $a . " - FALSE NEGATIVE!"
			}
			$n += $z;
			$z += '$c';
		} else {
			if ($match) {
				say $a . " - FALSE POSITIVE!"
			}
		}
	}
'
