#!/bin/bash

if [ -z "$1" ]; then
	echo "Usage: $0 FILE"
	echo 'Reads a regex calculating base 2 logarithm in the domain "^((x+)(?=\2$))*x$"'
    echo 'from FILE and feeds it powers of 2, printing the ones that match.'
	exit
fi

regex=$(tr -d '[:space:]' < "$1" | sed -e 's/(?#[^)]*)//g')

echo Regex length = $(echo -n "$regex"|wc -c)
echo Regex md5sum = $(echo -n "$regex"|md5sum)
echo

echo -n "$regex" |
perl -E '
	$regex = <>;
	for ($a=1;;$a*=2)  {
		@match = ("x" x $a) =~ /$regex(.*)/;
		if (@match) {
			say $a . " -> " . ($a - length(@match[-1]));
		} else {
            say $a . " -> no match";
        }
	}
'
