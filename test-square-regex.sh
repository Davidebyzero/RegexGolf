#!/bin/bash

regex=$(tr -d '[:space:]' < "regex for matching squares.txt" | sed -e 's/(?#[^)]*)//g')

echo Regex length = $(echo -n "$regex"|wc -c)
echo Regex md5sum = $(echo -n "$regex"|md5sum)
echo

a0=-1

perl -E '
	foreach my $a (0..100)  {
		say "x" x ($a*$a);
		#if ($a * $b == $c) {
			say "@" . ($a*$a);  # allow detection of false negatives
		#}
	}
	' |
# too small a --buffer-size will result in falsely detected false positives and negatives
pcregrep --buffer-size=1M --line-buffered -e"$regex" -e'^@' |
while read -r a
do
	if [[ ${a:0:1} = '@' ]]; then
		a=${a:1}
		if [[ $a -ne $a0 ]]; then
			echo $a "- FALSE NEGATIVE!"
		fi
		continue
	fi

	a0=${#a}

	echo $a0
done
