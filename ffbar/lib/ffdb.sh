#!/bin/bash
# extract movie meta to DB

function insertMeta() {
    sqlite3 ./lib/cinema.db <<EOF
        insert into movie values (
            null,
            '$title',
            '$long',
            '$watched',
            '$eps'
        );
EOF
}

function cleanTitle() {
    title="${inmvi##*/}"
    title=$(echo $title \
            | sed 's/\.mkv//;s/\.avi//;s/\.mp4//' \
            | sed 's/\./ /g' \
            | sed 's/(//;s/)//')

    title=$(echo $title \
            | sed -r 's/] /]/g;s/ \[/\[/g;
                s/\[[^][]*\]//g')

    if ! [[ "$title" =~ ^(19|20)[0-9][0-9].* ]]
    then
        title=$(echo $title \
            | sed -r 's/(.*[S,s][0-9][0-9]) (.*)/\1/' \
            | sed -r 's/(.*(19|20)[0-9][0-9]) (.*)/\1/' \
            | sed -r 's/ (720|1080)p.*//' \
            | sed -r 's/ [Bb][Ll][Uu][^"]{0,1}[Rr][Aa][Yy].*//' \
            | sed -r 's/ [Bb][Dd] [Rr][Ee][Mm][Uu][Xx].*//')
    fi
    echo "[dbg]: clean title: $title"
}

function extraMeta() {
    watched=`date +%b-%y`
    cleanTitle
    eps=$ctall
    if [ $eps -eq 1 ]
    then
        long=$fulltime
    elif [ $eps -gt 1 ]
    then
        long=$fulltimeTV
    fi
    insertMeta
}
