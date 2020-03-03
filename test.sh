#!/bin/bash

errors=0

# COLORS
CC='\033[0m'
CR='\033[0;31m'
CG='\033[0;32m'

function log() {
    echo "[*] $1"
}

function err() {
    echo "[-] $1"
    errors="$((errors + 1))"
}

function run_args() {
    local name
    local arg
    name="$1"
    arg="$2"
    log "running test '$name' ..."
    ./bash-to-fish.sh --debug test/"$name"/sample.sh || { err "failed to compile"; return; }
    ./bash-to-fish.sh test/"$name"/sample.sh test/"$name"/out.fish || { err "failed to compile"; return; }

    fish test/"$name"/out.fish "$arg" || { err "failed to run"; return; }
}

function run() {
    local name
    name="$1"
    log "running test '$name' ..."
    ./bash-to-fish.sh --debug test/"$name"/sample.sh || { err "failed to compile"; return; }
    ./bash-to-fish.sh test/"$name"/sample.sh test/"$name"/out.fish || { err "failed to compile"; return; }

    fish test/"$name"/out.fish || { err "failed to run"; return; }
}

run_args args --help
run func

echo ""
if [ "$errors" != "0" ]
then
    echo -e "[${CR}-${CC}] failed with $errors errors."
else
    echo -e "[${CG}+${CC}] test successful."
fi
