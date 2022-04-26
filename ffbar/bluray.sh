#!/bin/bash
# remux blu-ray BDMV data

inmvi=$1

function checkInput() {
	if [ ! -d "$inmvi" ]
	then
		echo "[err]:set bdmv dir"
		exit 1
	fi
	inmvi=$(rmSlashName "$inmvi")
}

function rmSlashName() {
	dslash="$1"
	chlast="${dslash: -1}"
		if [ $chlast = "/" ]
		then
			dslash="${dslash::-1}"
		fi
	echo "$dslash"
}

function elapseTime() {
	modeTime="$1"
	if [ "$modeTime" = "start" ]
	then
		startime=$(date +%s)
	elif [ "$modeTime" = "end" ]
	then
		endtime=$(date +%s)
		runtime=$((endtime-startime))
		runH=$(($runtime / 3600))
		runM=$((($runtime / 60) % 60))
		runS=$((runtime % 60))
		printf '[info]: elapsed: %02d:%02d:%02d\n' $runH $runM $runS
	fi

}

function setStream()
{
	read -p "[action]:set mpls file? [00001] " pls
	fepd="$inmvi/BDMV/PLAYLIST/$pls.mpls"
	flog="${inmvi##*/}"
}

function fgMKV() {
	elapseTime "start"
	mkvmerge --gui-mode -o "$inmvi".mkv "$fepd"\
		| grep --line-buffered -i 'progress'\
		> /tmp/mkvmerge.log &
	procID=$!
	sleep 10
	showProgress
	elapseTime "end"
	removeLoad
}

function showProgress() {
	echo "[info]:run blu-ray decoder"
	while kill -0 $procID >/dev/null 2>&1
	do
	sleep 2 
	mkvperc=$(tail -1 /tmp/mkvmerge.log\
			| tr -d '\0'\
			| sed "s/^#GUI#progress //; s/%//") 
		if [ ! -z "$mkvperc" ]
		then
			progressLine
			echo -ne "$progline   $mkvperc%\r"
		fi
	done
	echo "$progline   100% $flog"
}

function progressLine() {
	percdiv=$(expr $mkvperc / 10)

	progline="#"
	progit=1
	while [[ $progit -le $percdiv ]]
	do
		progline=$progline"#"
		((progit++))
	done
}

function removeLoad() {
	./movie.sh "$inmvi".mkv
	rm -r "$inmvi"
}

checkInput
setStream
fgMKV
