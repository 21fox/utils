#!/bin/bash
# database query

qmonth="$1"

function checkMonth() {
    allmonth="Jan Feb Mar Apr May Jun Jul Aug Sept Oct Nov Dec"
    qmonth=${qmonth^}
        if ! [[ " $allmonth " =~ " $qmonth " ]]
        then
            echo -e "[err]:set correct month -> \n$allmonth"
            exit 1
        fi
}

function getMvi() {
    if [ -z "$qmonth" ]
    then
       sqlite3 -batch ./lib/cinema.db "select * from movie"
    else
        checkMonth
        qmonth="${qmonth^}-`date +%y`"
        sqlite3 -batch ./lib/cinema.db \
                        "select * from movie \
                                where watched='$qmonth'"
    fi
}
getMvi