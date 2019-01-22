#!/bin/bash

if [ -z "$1" ]; then
	echo "Usage: $0 FILE"
	echo "Reads a regex matching Fibonacci numbers from FILE and tests it."
	exit
fi

regex=$(perl -0pe 's/(?<!\\)\s*|\(\?#[^)]*\)|(?<!\(\?)#.*$//gm' < "$1")

echo Regex length = $(echo -n "$regex"|wc -c)
echo Regex md5sum = $(echo -n "$regex"|md5sum)
echo

echo -n "$regex" |
perl -E '
	$regex = <>;
	$s = 0;
	$t = 1;
	foreach my $a (0..2584)  {
		$match = ("x" x ($a)) =~ /$regex/;
		if ($a == $s) {
			if ($match) {
				say $a
			} else {
				say $a . " - FALSE NEGATIVE!"
			}
			$z = $s;
			$s = $t;
			$t += $z;
			if ($t == 1) {
				$t = 2;
			}
		} else {
			if ($match) {
				say $a . " - FALSE POSITIVE!"
			}
		}
	}
'
