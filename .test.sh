#!/bin/bash

set -xe

export JAVA_HOME=$(readlink -f $(dirname $(readlink -f $(which java)))/../..)

cd /pyjnius 

identify() {
    cat /etc/issue &> "$1"
    java -version  &>> "$1" 
    python --version &>> "$1" 
    python3 --version &>> "$1"
}

OUTFILE="$1"

trybuild() {
    git clean -xfd
    identify "$OUTFILE".fail
    if make "$@" &>> "$OUTFILE".fail && make "$@" tests &>> "$OUTFILE".fail; then
        cat "$OUTFILE".fail >> "$OUTFILE".ok
        rm "$OUTFILE".fail
    else
        rm -f "$OUTFILE".ok
        exit 1
    fi
}

trybuild
trybuild PYTHON3=yes
