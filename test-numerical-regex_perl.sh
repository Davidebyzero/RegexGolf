#!/bin/bash

if [ -z "$3" ]; then
	echo "Usage: $0 FILE FIRST LAST"
	echo 'Reads a regex matching something in the domain "^x*$" from FILE and feeds it all'
    echo 'numbers in the range FIRST to LAST, printing the ones that match.'
	exit
fi

regex=$(perl -0pe 's/(?<!\\)\s*|\(\?#[^)]*\)|(?<!\(\?)#.*$//gm' < "$1")

echo Regex length = $(echo -n "$regex"|wc -c)
echo Regex md5sum = $(echo -n "$regex"|md5sum)
echo

echo -n "$regex" |
perl -E '
	$regex = <>;
	$n = 0;
	$z = 1;
	foreach my $a ('"$2"'..'"$3"')  {
		@match = ("x" x $a) =~ /$regex/;
		if (@match) {
			say $a # . " -> " . length(@match[0]);
		}
	}
'
