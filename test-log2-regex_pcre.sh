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

listen=1
out='no match'

perl -E '
	for ($a=1;;$a*=2)  {
		say "x" x ($a);
        say "@" . $a;
	}
	' |
# too small a --buffer-size will result in falsely detected false positives and negatives
pcregrep -H --label=':' -o --buffer-size=2M --line-buffered --match-limit=1000000000 -e"$regex" -e'^@.*' |
while read -r a
do
    a=${a:2}
	if [[ ${a:0:1} = '@' ]]; then
	    echo ${a:1} '->' $out
        out='no match'
        listen=1
    elif [[ $listen = 1 ]]; then
        out=${#a}
        listen=0
    fi
done
