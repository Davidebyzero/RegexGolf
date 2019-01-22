#!/bin/bash

if [ -z "$1" ]; then
	echo "Usage: $0 FILE"
	echo "Reads a Multiplication regex from FILE and tests it."
	exit
fi

regex=$(perl -0pe 's/(?<!\\)\s*|\(\?#[^)]*\)|(?<!\(\?)#.*$//gm' < "$1")

echo Regex length = $(echo -n "$regex"|wc -c)
echo Regex md5sum = $(echo -n "$regex"|md5sum)
echo

echo -n "$regex" |
perl -E '
	$regex = <>;
	foreach my $a (1.. 12)  {
	foreach my $b (1.. 12)  {
	foreach my $c (1..144) {
		$match = ("x" x ($a) . "*" . "x" x ($b) . "=" . "x" x ($c)) =~ /$regex/;
		if ($a * $b == $c) {
			if ($match) {
				say $a . " * " . $b . " = " . $c;
			} else {
				say $a . " * " . $b . " != " . $c . " - FALSE NEGATIVE!";
			}
		} else {
			if ($match) {
				say $a . " * " . $b . " = " . $c . " - FALSE POSITIVE!"
			}
		}
	}}}
'
