#!/usr/bin/env bash
set -uo pipefail 

ERR_WRONG=113

log() {
  printf -- "${1}\n" 
  printf -- "${1}\n" >> "${2}"
}

# returns user's input.
# examples:
# required input: v=$( get_input "Please enter variable" 1 )
# output: Please enter variable: 
# non required input: v=$( get_input "Please enter variable" )
# output: Please enter variable (optional): 
get_input() {
    local req=${2-0}
    local silently=${3-0}
    if (( $req == 1 )); then
        echo -e -n "$1: " >&2
    else
        echo -e -n "$1 (optional): " >&2
    fi
    
    if (( $silently == 1)); then
        read -s res
    else
        read res
    fi

    #if string is not empty or not required
    if [[ -n "${res}" ]] || (( $req != 1 )); then
        echo "$res"
    else
        while [ -z $res ]; do
			echo -e -n "$1: " >&2

            if (( $silently == 1)); then
                read -s inp
            else
                read inp
            fi

            res=$inp
        done
        echo "$res"
    fi  
}

is_success() {
    if [[ $? -ne 0 ]]; then
        echo "false"
    else
        echo "true"
    fi
}

assert_success() {
    if [[ $? -ne 0 ]]; then
        echo -e "Something went wrong.\nFor more information see logs."
        exit $ERR_WRONG
    fi
}

get_os_info() {
    local OS=""
    local VER=""

    if [ -f /etc/os-release ]; then
        # freedesktop.org and systemd
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
    # elif [ -f /etc/lsb-release ]; then
    #     # For some versions of Debian/Ubuntu without lsb_release command
    #     . /etc/lsb-release
    #     OS=$DISTRIB_ID
    #     VER=$DISTRIB_RELEASE
    # elif [ -f /etc/debian_version ]; then
    #     # Older Debian/Ubuntu/etc.
    #     OS=Debian
    #     VER=$(cat /etc/debian_version)
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
        echo "${OS} ${VER}"
    fi
}

get_supported_os_code() {
    IFS=$'\n'       # make newlines the only separator
    set -f          # disable globbing
    local res=""
    for line in $(sudo cat < $2); do
        if [[ "${1}" == "${line}" ]]; then
            res="${1// /_}"
            break
        fi
    done

    echo "${res}"
}

arr_contains_element() {
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