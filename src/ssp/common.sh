#!/usr/bin/env bash
set -uo pipefail 

ERR_WRONG=113

function log() {
  printf -- "${1}\n" 
  printf -- "${1}\n" >> "${2}"
}

function get_required_input() {
	echo -e -n "$1: " >&2
    read res
    #if string is not empty
    if [[ -n "${res}" ]]; then
        echo "$res"
    else
        while [ -z $res ]; do
			echo -e -n "$1: " >&2
            read inp
            res=$inp
        done
        echo "$res"
    fi  
}

function assert_success() {
    if [[ $? -ne 0 ]]; then
        echo -e "Something went wrong.\nFor more information see logs."
        exit $ERR_WRONG
    fi
}

function get_os_info() {
    local OS=""
    local VER=""

    if [ -f /etc/os-release ]; then
        # freedesktop.org and systemd
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        # linuxbase.org
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        # For some versions of Debian/Ubuntu without lsb_release command
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    elif [ -f /etc/debian_version ]; then
        # Older Debian/Ubuntu/etc.
        OS=Debian
        VER=$(cat /etc/debian_version)
    #elif [ -f /etc/SuSe-release ]; then
        # Older SuSE/etc.
        #...
    #elif [ -f /etc/redhat-release ]; then
        # Older Red Hat, CentOS, etc.
        #...
    else
        # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
        OS=""
        VER=""
    fi

    if [[ -z "${OS}" ]] && [[ -z "${VER}" ]]; then
        echo ""
    else
        echo "$OS $VER"
    fi
}

function get_version_code() {
    local pat="^([[:alpha:]][[:alpha:]]*_[[:digit:]][[:digit:]]*) # $1$"

    IFS=$'\n'       # make newlines the only separator
    set -f          # disable globbing
    local res=""
    for line in $(sudo cat < $2); do
        if [[ $line =~ $pat ]]; then
            res="${BASH_REMATCH[1]}"
            break
        fi
    done

    echo "${res}"
}

function arr_contains_element() {
    local arr=$1[@]
    local res=""
    for el in "${arr[@]}"; do
        if [[ "${el}" == "${2}" ]]; then
            res="${2}"
            break
        fi
    done
    
    echo "${res}"
}