#!/bin/bash

if [ -z "$1" ]; then
	echo "Usage: $0 FILE"
	echo 'Reads a regex calculating base 2 logarithm in the domain "^((x+)(?=\2$))*x$"'
    echo 'from FILE and feeds it powers of 2, printing the ones that match.'
	exit
fi

regex=$(perl -0pe 's/(?<!\\)\s*|\(\?#[^)]*\)|(?<!\(\?)#.*$//gm' < "$1")

echo Regex length = $(echo -n "$regex"|wc -c)
echo Regex md5sum = $(echo -n "$regex"|md5sum)
echo

out='no match'

perl -E '
	for ($a=1; $a<=9223372036854775808; $a*=2)  {
        say $a;
	}
' |
regex.exe -nx -f"$1" --verbose
