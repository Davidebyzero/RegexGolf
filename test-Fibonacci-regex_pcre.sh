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

a0=-1
s=0
t=1

perl -E '
	$s = 0;
	$t = 1;
	foreach my $a (0..2584)  {
		say "x" x ($a);
		if ($a == $s) {
			say "@" . ($a);  # allow detection of false negatives
			$z = $s;
			$s = $t;
			$t += $z;
			if ($t == 1) {
				$t = 2;
			}
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
		z=$s
		s=$t
		t=$(($t + $z))
		if [ $t -eq 1 ]; then
			t=2  # don't do 1 twice in a row
		fi
		continue
	fi

	a0=${#a}

	echo -n $a0
	if [[ ${#a} -ne $s ]]; then
		echo " - FALSE POSITIVE!"
	else
		echo
	fi
done
