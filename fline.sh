#!/bin/bash
# fline.sh append N lines src to dest

if [ "$#" -ne 4 ]
then
	echo "[err]:set first last lines src dest files"
	exit 1
fi

: '
lfirst="$1"
llast="$2"
fsrc="$3"
fdest="$4"
'

sed -n "$1,$2p" < "$3" >> "$4"
