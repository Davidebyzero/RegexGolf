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

regex=$(perl -0pe 's/(?<!\\)\s*|\(\?#[^)]*\)|(?<!\(\?)#.*$//gm' < "$1")

echo Regex length = $(echo -n "$regex"|wc -c)
echo Regex md5sum = $(echo -n "$regex"|md5sum)
echo

a0=-1
n=0
z=1
c=$(($1 - 2))

perl -E '
	$n = 0;
	$z = 1;
	foreach my $a (0..2025)  {
		say "x" x ($a);
		if ($n == $a) {
			say "@" . ($a);  # allow detection of false negatives
			$n += $z;
			$z += '$c';
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
		z=$(($z + $c))
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
