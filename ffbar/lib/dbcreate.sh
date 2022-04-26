#!/bin/bash
# create movie meta DB

sqlite3 ./lib/cinema.db <<EOF
create table movie (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT,
    long TEXT,
    watched TEXT,
    eps INTEGER
    );
EOF