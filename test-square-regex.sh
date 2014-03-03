#!/bin/bash

if [ -z "$1" ]; then
	echo "Usage: $0 FILE"
	echo "Reads a Perfect Square regex from FILE and tests it."
	exit
fi

regex=$(tr -d '[:space:]' < "$1" | sed -e 's/(?#[^)]*)//g')

echo Regex length = $(echo -n "$regex"|wc -c)
echo Regex md5sum = $(echo -n "$regex"|md5sum)
echo

a0=-1
n=0
z=1

perl -E '
	$n = 0;
	$z = 1;
	foreach my $a (0..2025)  {
		say "x" x ($a);
		if ($n == $a) {
			say "@" . ($a);  # allow detection of false negatives
			$n += $z;
			$z += 2;
		}
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
		n=$(($n + $z))
		z=$(($z + 2))
		continue
	fi

	a0=${#a}

	echo -n $a0
	if [[ ${#a} -ne $n ]]; then
		echo " - FALSE POSITIVE!"
	else
		echo
	fi
done
