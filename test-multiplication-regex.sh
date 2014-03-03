#!/bin/bash

if [ -z "$1" ]; then
	echo "Usage: $0 FILE"
	echo "Reads a Multiplication regex from FILE and tests it."
	exit
fi

regex=$(tr -d '[:space:]' < "$1" | sed -e 's/(?#[^)]*)//g')

echo Regex length = $(echo -n "$regex"|wc -c)
echo Regex md5sum = $(echo -n "$regex"|md5sum)
echo

a0=""
b0=""
c0=""

perl -E '
	foreach my $a (1.. 12)  {
	foreach my $b (1.. 12)  {
	foreach my $c (1..144) {
		say "x" x $a . "*" . "x" x $b . "=" . "x" x $c;
		if ($a * $b == $c) {
			say "@" . $a . "*" . $b . "=" . $c;  # allow detection of false negatives
		}
	}}}
	' |
# too small a --buffer-size will result in falsely detected false positives and negatives
pcregrep --buffer-size=1M --line-buffered -e"$regex" -e'^@' |
while read -r result
do
	a=${result%%\**}
	b=${result#*\*}
	b=${b%%=*}
	c=${result#*=}

	if [[ ${a:0:1} = '@' ]]; then
		a=${a:1}
		if [[ $a -ne $a0 || $b -ne $b0 || $c -ne $c0 ]]; then
			echo $a \* $b != $c "- FALSE NEGATIVE!"
		fi
		continue
	fi

	a0=${#a}
	b0=${#b}
	c0=${#c}

	echo -n ${#a} \* ${#b} = ${#c}
	if [[ ${#a}*${#b} -ne ${#c} ]]; then
		echo " - FALSE POSITIVE!"
	else
		echo
	fi
done
