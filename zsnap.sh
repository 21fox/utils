#!/bin/bash

showHelp() {
	echo -e "\
zsnap options:\n\
\t[zfs name] create snapshot default TTL is 1m\n\
\t-t {1-99}[m|d] [zfs name] create snapshot with TTL m-month d-day\n\
\t-m {1-99} [zfs name] if-modified snapshot with numeric limit\n\
\t\tcall with new limit removes snapshots with higher number\n\
\t-r recursion flag for zfs\n\
\t-d cleanup expired snapshots\n\
\t-h show CLI options"
}

deflTTL() { ittl=1m ; }

parseArg() {
	if [[ ${1:0:1} != "-" ]]
	then
		ishft=1
		deflTTL
		runTTL "$@"
	else
	while getopts ":t:m:rdh" opt
	do
		case $opt in
		t) 
			ishft=1
			ittl=$OPTARG
			fmtTTL
			runTTL "$@";;
		r)
			if [ -z "$ittl" ]
			then
				deflTTL
				ishft=2
				runTTL "$@"
			fi;;
		d)
			indlv="rem"
			remTTL;;
		m)
			ishft=1
			iqnt=$OPTARG
			fmtQNT
			runQNT "$@";;
		h)
			deflTTL
			showHelp
			exit 1;;
		:)
			echo "[err]: -$OPTARG requires arg" >&2 
			exit 1;;
		*)
			echo "[err]: no option: -$OPTARG" >&2
			exit 1;;
		esac
	done
	fi	
}

fmtTTL() {
	regi="^[1-9][0-9][m|d]?$"
	if [[ ! $ittl =~ $regi ]]
	then
		echo "[err]: ttl indicator format $regi"
		exit 1
	fi
}

fmtQNT() {
	regi="^[1-9][0-9]?$"
	if [[ ! $iqnt =~ $regi ]]
	then
		echo "[err]: qnt indicator format $regi"
		exit 1
	fi
}

parseZFS() {
	shift $((OPTIND-$ishft))
	if [[ $# -lt 1 ]]
	then
		echo "[err]: set zfs"
		exit 1
	fi
	
	zlist=()
	for z in "$@"
	do 
		arrZFS "$z"
	done
	checkZFS
}

arrZFS() {
	lastList

	if [[ "$zlast" = "-r" && "$opt" = "m" ]]
	then
		echo "[err]: -r not allowed for -$opt option"
		exit 1
	fi

	if [ "$zlast" = "-r" ]
	then
		zlist[$dec]="${zlist[$dec]} $1"
	else
		zlist+=("$1")
	fi
}

lastList() {
	zsize="${#zlist[@]}"
	if [ $zsize -gt 0 ]
	then
		dec=$(($zsize-1))
		zlast=${zlist[$dec]}
	fi
}

checkZFS() {
	for i in "${!zlist[@]}"
	do
		zfs list ${zlist[$i]} &>/dev/null
		iszf=$?
		if [[ ${zlist[$i]} = "-r" || $iszf -ne 0 ]]
		then
			echo "[err]: no zfs '${zlist[$i]}' run zfs list"
			exit 1
		fi
	done
}

makeTTL() {
	nmsnap=$(date '+%m%d%y')"-$ittl"
	for i in "${!zlist[@]}"
	do
		zfs snapshot ${zlist[$i]}@"$nmsnap"
	done
}

makeQNT() {
	for i in "${!zlist[@]}"
	do
		chgQNT
		ischg=$?
		if [ $ischg -eq 1 ]
		then
			nmsnap=$(date '+%m%d%y')"-$iqnt"
			zfs snapshot ${zlist[$i]}@"$nmsnap"
		fi
	done
}

cleanQNT() {
	aqnt=$(zfs list -Hp -r -t snapshot -o name ${zlist[$i]}\
			| grep -E ".*-[0-9]{1,2}$" | wc -l | sed 's/^ *//g')
	aqnt=$((aqnt-iqnt))
	if [ $aqnt -ge 0 ]
	then
		osnap=$(zfs list -Hp -r -t snapshot -o name ${zlist[$i]}\
			| grep -E ".*-[0-9]{1,2}$" | head -$((aqnt+1)))
	
		for o in $osnap
		do
			zfs destroy "$o"
		done
	fi
}

chgQNT() {
	qsnap=$(zfs list -Hp -r -t snapshot -o name\
			| grep -E "${zlist[$i]}@.*-[0-9]{1,2}$" | tail -1)
	if [[ -z "$qsnap" ]]
	then
		return 1
	else
		if [[ $(zfs diff "$qsnap" "${zlist[$i]}") ]]
		then
			cleanQNT
			return 1
		else
			return 0
		fi
	fi
}

remTTL() {
	zfset=$(zfs list -Hp -t snapshot -o name\
			| grep -E ".*-[0-9]{1,2}[m|d]$")
	for z in $zfset
	do
		zdfs=$(sed 's/@.*//' <<< $z)
		snap=$(sed 's/.*@//' <<< $z)
		expTTL
		isexp=$?
		if [ $isexp -eq 1 ]
		then
			zfs destroy "$z"
		fi
	done
}

expTTL() {
	stdate=$(sed 's/-.*//' <<< $snap)
	exp=$(sed 's/.*-//' <<< $snap)
	endate=$(date -v+$exp -ujf'%m%d%y' $stdate '+%m%d%y')
	dateDiff
	if [[ ddif -le 0 ]]
	then
		return 1
	else 
		return 0
	fi
}

dateDiff() {
	stdatef=$(date +%s)
	endatef=$(date -jf '%m%d%y' "$endate" +%s)
	ddif=$(( (endatef - stdatef) / 86400 ))
}

runTTL() {
	parseZFS "$@"
	makeTTL
}

runQNT() {
	parseZFS "$@"
	makeQNT
}

parseArg "$@"
