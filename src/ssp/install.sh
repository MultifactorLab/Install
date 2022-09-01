#!/usr/bin/env bash
set -uo pipefail

SCRIPT_VERSION="1.0"

# Error codes
ERR_SUDO_PRIV=64
ERR_SCR_NOT_FOUND=65
ERR_UNKNOWN_OS=66
ERR_UNSUPPORTED_OS=67
ERR_ALREADY_EXECUTING=68

# Run as a superuser and do not ask for a password. Exit status as successful
sudo -n true

# Test the last variable's exit code and see if it equals '0'. 
# If not, exit with an error and print a given message to the terminal.
if (( $? != 0 )); then
    echo "You should have sudo privilege to run this script"
    exit $ERR_SUDO_PRIV
fi
# current dir
MFA_SCRIPT_DIR="$(dirname ${BASH_SOURCE[0]})"
# log file
MFA_OUTPUT_FILE="$MFA_SCRIPT_DIR/install-log.txt"

# prevent to start multiple script instances
LOCKFILE="${MFA_SCRIPT_DIR}/lock"
if [ -f "${LOCKFILE}" ]; then
    echo -e "Only one script instance can be run!\nStop another instance or remove this file: ${LOCKFILE}"
    exit $ERR_ALREADY_EXECUTING
else 
    touch "${LOCKFILE}"
fi

_SKIPPED_STEPS=( "EMPTY" )
_OFFLINE_MODE=1
_TRASH=()
cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
    sudo rm -f "${LOCKFILE}"

    if (( $_OFFLINE_MODE == 0 )); then
        for path in "${_TRASH[@]}"; do
            if [ -d "${path}" ] && [ -e "${path}" ]; then
                sudo rm -r "${path}"
            fi

            if [ -f "${path}" ] && [ -e "${path}" ]; then
                sudo rm "${path}"
            fi
        done
    fi
}
trap cleanup SIGINT SIGTERM ERR EXIT

function try_download() {
    {
        wget --tries 2 --timeout 5 -O $2 $1
    } &>> "${MFA_OUTPUT_FILE}"
}

function check_file_exists() {
    if [ ! -f "${1}" ]; then
        echo -e "Script file was not found: ${1}.\nFor more information see logs."
        exit $ERR_SCR_NOT_FOUND
    fi  
}

function get_filename_from_path() {
    echo "$( basename -- "${@}" )"
}

function mark_as_trash() {
    _TRASH=( "${_TRASH[@]}" "${@}" )
}

usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-o] -p param_value arg1 [arg2...]

Script description here.

Available options:

-o,  --offline      prevent to download resources from the MultifactorLab repositories
-s,  --skip
EOF
    exit
}



######################
##  Get main files  ##
######################

REPO_BASE_PATH="https://raw.githubusercontent.com/MultifactorLab/Install/main/src/ssp"

COMMON_FILENAME="common.sh"
VAR_FILENAME="variables.sh"
VER_FILENAME="versions"
DEPS_FILENAME="deps"
PIPELINE_FILENAME="pipeline"
LOGO_FILENAME="logo"

echo "Downloading required files..." > "${MFA_OUTPUT_FILE}"

function get_req_files() {
    local files=("${COMMON_FILENAME}" "${VAR_FILENAME}" "${VER_FILENAME}" "${DEPS_FILENAME}" "${PIPELINE_FILENAME}" "${LOGO_FILENAME}")
    for file in "${files[@]}"; do
        local f_name=$( get_filename_from_path "${file}" )
        local file_path="${MFA_SCRIPT_DIR}/${f_name}"

        if (( $_OFFLINE_MODE == 0 )); then
            try_download "${REPO_BASE_PATH}/${file}" "${file_path}"
        fi
       
        check_file_exists "${file_path}"
        mark_as_trash "${file_path}"
    done
}
get_req_files

. "${MFA_SCRIPT_DIR}/${COMMON_FILENAME}"
. "${MFA_SCRIPT_DIR}/${VAR_FILENAME}"

function write_log() {
    log "${@}" "${MFA_OUTPUT_FILE}"
}



########################
##  Check OS version  ##
########################
OS_INFO=$( get_os_info )
if [[ -z "${OS_INFO}" ]]; then
    write_log "Unknown OS version"
    exit $ERR_UNKNOWN_OS
fi

VERSION_CODE=$( get_supported_os_code "${OS_INFO}" "${MFA_SCRIPT_DIR}/${VER_FILENAME}" )
if [[ -z "${VERSION_CODE}" ]]; then
    write_log "Unsupported OS version: ${OS_INFO}"
    exit $ERR_UNSUPPORTED_OS
fi



####################
##  Show WELCOME  ##
####################
LOGO_FILE="${MFA_SCRIPT_DIR}/${LOGO_FILENAME}"
if [ -f "${LOGO_FILE}" ]; then
    cat "${LOGO_FILE}"
fi

echo -e "\n\n Self Service Portal for Linux Installer"
CUR_YEAR=$(date +"%Y")
echo -e " Copyright (c) ${CUR_YEAR} MultiFactor"
echo " Release: ${OS_INFO}"
echo " Version: ${SCRIPT_VERSION}"
echo " ----------------------------------------------------"

sleep 1

NOW=$(date +'%d.%m.%Y %H:%M:%S')
echo "Starting at ${NOW}. Release: ${OS_INFO}. Version code: ${VERSION_CODE}" > "${MFA_OUTPUT_FILE}"



#############################
##  Download dependencies  ##
#############################
write_log "\nGetting required modules"

function get_deps() {
    for path in $(sudo cat < "${MFA_SCRIPT_DIR}/${DEPS_FILENAME}"); do
        local dir=$(dirname $path)
        if [[ "${dir}" != "." ]]; then
            local d_name="${MFA_SCRIPT_DIR}/${dir}"
            sudo mkdir -p "${d_name}"
            sudo chmod 777 "${d_name}"

            mark_as_trash "${d_name}"
        fi
    
        local f_name="${MFA_SCRIPT_DIR}/${path}"
        if (( $_OFFLINE_MODE == 0 )); then
            try_download "${REPO_BASE_PATH}/${path}" "${f_name}"
        fi
        check_file_exists "${f_name}"
    done
}
get_deps



########################
##  Download modules  ##
########################
MODULES_DIR="${MFA_SCRIPT_DIR}/modules"
sudo mkdir -p "${MODULES_DIR}"
sudo chmod 777 "${MODULES_DIR}"
mark_as_trash "${MODULES_DIR}"

MODULES=()

function get_modules() {
    for mod_file in $(sudo cat < "${MFA_SCRIPT_DIR}/${PIPELINE_FILENAME}"); do 
        local skipped=$( arr_contains_element $_SKIPPED_STEPS "${mod_file}" )
        if [[ -n "${skipped}" ]]; then
            continue
        fi    

        local f_src="${REPO_BASE_PATH}/modules/${VERSION_CODE}/${mod_file}.sh"
        local f_dst="${MODULES_DIR}/${mod_file}.sh"

        if (( $_OFFLINE_MODE == 0 )); then
            try_download "${f_src}" "${f_dst}"
        fi
        check_file_exists "${f_dst}"
        sudo chmod -x "${f_dst}"

        MODULES=( "${MODULES[@]}" "${f_dst}" )
        mark_as_trash "${f_dst}"
    done
}
get_modules

sudo chmod 777 -R $MFA_SCRIPT_DIR



###################
##  Run modules  ##
###################
function run_modules() {
    for mod_file in "${MODULES[@]}"; do 
        if [ ! -f "${mod_file}" ]; then
            continue
        fi
        
        . "${mod_file}"
        assert_success
    done
}
run_modules

write_log "\nSelf Service Portal installed successfully\n"

exit 0