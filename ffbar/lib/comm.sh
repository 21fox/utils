#!/bin/bash
# common function for sharing usage

function timeToDate() {
	tdate=$1
	tdate=$( \
    printf '%02d:%02d:%02d\n'\
        $((tdate/3600)) \
        $(((tdate / 60) % 60)) \
        $((tdate%60)) \
    )
	echo "$tdate"
}

function timeToSec() {
	sec=$(echo $1\
		| awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')
	echo "$sec"
}
