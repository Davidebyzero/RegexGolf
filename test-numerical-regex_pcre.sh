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

perl -E '
	foreach my $a ('"$2"'..'"$3"')  {
		say "x" x ($a);
	}
	' |
# too small a --buffer-size will result in falsely detected false positives and negatives
pcregrep --buffer-size=2M --line-buffered --match-limit=1000000000 -e"$regex" -e'^@' |
while read -r a
do
	echo ${#a}
done
