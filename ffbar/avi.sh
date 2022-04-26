#!/bin/bash
# decode avi -> mp4

. ./lib/ffwrap.sh
. ./lib/ffdb.sh

inmvi=$1

function checkInput() {
	if [ ! -f "$inmvi" ]
	then
		echo "[err]:set avi file"
		exit 1
	fi
	echo -e "\n[info]:start fformat movie prompt\n"
}

function setArg() {
		ffarg=(\
			-i "$inmvi"\
			-c:v copy -c:a copy\
            -y "$ftv"
		)
}

function setFileName() {
    	fepd="$inmvi"
		ftv=$(sed 's/\.avi/\.mp4/' <<< "$inmvi")
	flog="${inmvi##*/}"
}

function setPrgsMeta() {
	ctall=1
	ctitr=1
}

function fgFF() {
	elapseTime "start"
	ffmpeg "${ffarg[@]}" 2>"/tmp/ffdirty.log" &
	procID=$!
    		setPrgsMeta
    		showProgress
	elapseTime "end"
	extraMeta
		removeLoad
}

function getRun() {
	setFileName
	setArg
	fgFF
}

checkInput
getRun
