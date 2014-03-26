#!/bin/bash

if [ -z "$1" ]; then
	echo "Usage: $0 FILE"
	echo "Reads a Perfect Square regex from FILE and tests it."
	exit
fi

exec "$(dirname "$0")/test-polygonal-number-regex_pcre.sh" 4 "$1"
