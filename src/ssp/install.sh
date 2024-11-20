#!/usr/bin/env bash
set -uo pipefail

SCRIPT_VERSION="1.5"

#######################################
# Error codes
#######################################
ERR_SUDO_PRIV=64
ERR_FILE_NOT_FOUND=65
ERR_UNKNOWN_OS=66
ERR_UNSUPPORTED_OS=67
ERR_ALREADY_EXECUTING=68
ERR_UNEXPECTED_OPT=69
ERR_INCORRECT_OPT=70
ERR_INCORRECT_ARG=71

#######################################
# Flags
#######################################
FORCE_MODE='false'
SKIP='false'
POST_CLEANUP='true'

#######################################
# Check SUDO privilege
#######################################
# Run as a superuser and do not ask for a password. Exit status as successful
sudo -n true

# Test the last variable's exit code and see if it equals '0'. 
# If not, exit with an error and print a given message to the terminal.
if ! sudo -n true; then
    echo "You should have sudo privilege to run this script"
    exit $ERR_SUDO_PRIV
fi

#######################################
# Variables
#######################################
MFA_SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
MFA_OUTPUT_FILE="$MFA_SCRIPT_DIR/install-log.txt"

REPO_BASE_PATH="https://raw.githubusercontent.com/MultifactorLab/Install"
DEFAULT_BRANCH="main"
BRANCH_NAME="${DEFAULT_BRANCH}"

COMMON_FILE="${MFA_SCRIPT_DIR}/common.sh"
VAR_FILE="${MFA_SCRIPT_DIR}/variables.sh"
VER_FILE="${MFA_SCRIPT_DIR}/versions"
DEPS_FILE="${MFA_SCRIPT_DIR}/deps"
PIPELINE_FILE="${MFA_SCRIPT_DIR}/pipeline"
LOGO_FILE="${MFA_SCRIPT_DIR}/logo"

REQUIRED_FILES=("${COMMON_FILE}" "${VAR_FILE}" "${VER_FILE}" "${DEPS_FILE}" "${PIPELINE_FILE}" "${LOGO_FILE}")

SKIPPED_STEPS=( 'EMPTY' )
_TRASH=()

CUR_YEAR=$(date +"%Y")

#######################################
# Preventing multiple running
#######################################
LOCKFILE="${MFA_SCRIPT_DIR}/lock"
if [ -f "${LOCKFILE}" ]; then
    echo -e "Only one script instance can be run!\nStop another instance or remove this file: ${LOCKFILE}"
    exit $ERR_ALREADY_EXECUTING
else 
    touch "${LOCKFILE}"
fi

#######################################
# Removes temporary files and scripts
#######################################
# shellcheck disable=SC2317
cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
    sudo rm -f "${LOCKFILE}"

    if [[ "${POST_CLEANUP}" == 'true' ]]; then
        for path in "${_TRASH[@]+"${_TRASH[@]}"}"; do
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

get_repo_path() {
    echo "${REPO_BASE_PATH}/${BRANCH_NAME}/src/ssp"
}

#######################################
# Gets file from http
# Globals:
#  MFA_OUTPUT_FILE
# Arguments:
#  Remote file path
#  Local destination file path
#######################################
try_download() {
    {
        wget --tries 2 --timeout 5 -O "$2" "$1"
    } &>> "${MFA_OUTPUT_FILE}"
}

#######################################
# Checks that file exists
# Globals:
#  ERR_FILE_NOT_FOUND
# Arguments:
#  File path
#######################################
check_file_exists() {
    if [ ! -f "${1}" ]; then
        echo "File not found: ${1}"
        echo "For more information see logs."
        exit $ERR_FILE_NOT_FOUND
    fi  
}

#######################################
# Returns filename.extension from path
# Arguments:
#  File path
#######################################
get_filename_from_path() {
    echo "$( basename -- "${@}" )"
}

#######################################
# Marks file as trash
# Globals
#  _TRASH
# Arguments:
#  File path
#######################################
mark_as_trash() {
    _TRASH=( "${_TRASH[@]+"${_TRASH[@]}"}" "${@}" )
}

get_dependencies() {
    for path in $(sudo cat < "${DEPS_FILE}"); do
        local dir
        dir=$(dirname "$path")

        if [[ "${dir}" != "." ]]; then
            local d_name="${MFA_SCRIPT_DIR}/${dir}"
            if [ ! -d "${dir}" ]; then
                sudo mkdir -p "${d_name}"
                sudo chmod 777 "${d_name}"
            fi

            mark_as_trash "${d_name}"
        fi

        local f_name="${MFA_SCRIPT_DIR}/${path}"
        if [ -f "${f_name}" ] && [[ "${FORCE_MODE}" == 'false' ]]; then
            continue
        fi 

        repo_path=$( get_repo_path )
        try_download "${repo_path}/${path}" "${f_name}"
        check_file_exists "${f_name}"
    done
}

#######################################
# Get required files from server
# Globals:
#  MFA_OUTPUT_FILE
#  REQUIRED_FILES
#  FORCE_MODE
#######################################
get_req_files() {
    echo "Downloading required files..." > "${MFA_OUTPUT_FILE}"
    for file in "${REQUIRED_FILES[@]+"${REQUIRED_FILES[@]}"}"; do

        if [ -f "${file}" ] && [[ "${FORCE_MODE}" == 'false' ]]; then
            continue
        fi 

        local f_name
        f_name=$( get_filename_from_path "${file}" )
        repo_path=$( get_repo_path )
        try_download "${repo_path}/${f_name}" "${file}"       
       
        check_file_exists "${file}"
        mark_as_trash "${file}"

    done
}

#######################################
# Shaws information about this script and its arguments
#######################################
help() {
    cat <<EOF

Copyright (c) ${CUR_YEAR} MultiFactor
Self Service Portal Installer

Available options:
┌─────┬─────────────────────────────────────────────────────────┬─────────────────────────┐
│ Opt │ Description                                             │ Examples                │
├─────┼─────────────────────────────────────────────────────────┼─────────────────────────┤
│ -h  │ Display help.                                           │ install.sh -h           │
├─────┼─────────────────────────────────────────────────────────┼─────────────────────────┤
│ -i  │ Display information about this version.                 │ install.sh -i           │
├─────┼─────────────────────────────────────────────────────────┼─────────────────────────┤
│ -l  │ List installer stages. First will try to display stages │ install.sh -l           │
│     │ using available resources. If resources don't exist     │                         │
│     │ will try to get them from the MultiFactor repositories. │                         │
├─────┼─────────────────────────────────────────────────────────┼─────────────────────────┤
│ -f  │ Force mode. Forces to get required resources            │ install.sh -f           │
│     │ from the MultiFactor repositories. Overwrites existed   │                         │
│     │ files.                                                  │                         │
├─────┼─────────────────────────────────────────────────────────┼─────────────────────────┤
│ -c  │ No-cleanup mode. Prevents cleanup of temporary          │ install.sh -c           │
│     │ files and resources.                                    │                         │
├─────┼─────────────────────────────────────────────────────────┼─────────────────────────┤
│ -s  │ Skip specified installer stages.                        │ install.sh -s stg       │
│     │ To list all available stages run script                 │ install.sh -s stgA,stgB │
│     │ with option [-l].                                       │                         │
│     │ Arguments:                                              │                         │
│     │ Stage name (or names separated by commas).              │                         │
├─────┼─────────────────────────────────────────────────────────┼─────────────────────────┤
│ -S  │ Execute specified installer stages only.                │ install.sh -S stg       │
│     │ To list all available stages                            │ install.sh -S stgA,stgB │
│     │ run script with option [-l].                            │                         │
│     │ Arguments:                                              │                         │
│     │ Stage name (or names separated by commas).              │                         │
└─────┴─────────────────────────────────────────────────────────┴─────────────────────────┘

EOF
    exit 0
}

info() {
    echo "${SCRIPT_VERSION}"

    if [ ! -f "${VER_FILE}" ]; then
        repo_path=$( get_repo_path )
        try_download "${repo_path}/$(get_filename_from_path "${VER_FILE}")" "${VER_FILE}"
        check_file_exists "${VER_FILE}"
    fi 
    echo "Supported OS:"
    sudo cat "${VER_FILE}"; echo

    exit 0;
}

display_stages() {
    if [ ! -f "${PIPELINE_FILE}" ]; then
        repo_path=$( get_repo_path )
        try_download "${repo_path}/$(get_filename_from_path "${PIPELINE_FILE}")" "${PIPELINE_FILE}"
        check_file_exists "${PIPELINE_FILE}"
    fi 
    echo "Installer stages:"
    sudo cat "${PIPELINE_FILE}"; echo
    exit 0
}

parse_skip_args() {
    local patt="^[[:alpha:]][[:alpha:]]*(,[[:alpha:]][[:alpha:]]*)*$"
    if [[ ! "${1}" =~ ${patt} ]]; then
        echo "Invalid arguments after option [-s]"
        exit $ERR_INCORRECT_ARG
    fi

    SKIP='true'
    SKIPPED_STEPS=(${1//,/ })
}

#######################################
# Reads script arguments and sets flags
#######################################
while getopts ':hib:lfcs:' flag; do
    case "${flag}" in
        h) help ;;
        i) info ;;
        b) BRANCH_NAME="${OPTARG}" ;;
        l) display_stages ;;
        f) FORCE_MODE='true' ;;
        c) POST_CLEANUP='false' ;;
        s) parse_skip_args "${OPTARG}" ;;
        *) echo "Unexpected option" 
        exit $ERR_UNEXPECTED_OPT
        ;;
    esac
done

display_opts() {
    if [[ "${BRANCH_NAME}" != "${DEFAULT_BRANCH}" ]]; then
        echo "[Branch: ${BRANCH_NAME}]"
    fi

    if [[ "${POST_CLEANUP}" == 'false' ]]; then
        echo "[No-cleanup mode]"
    fi

    if [[ "${FORCE_MODE}" == 'true' ]]; then
        echo "[Force mode]"
    fi

    if [[ "${SKIP}" == 'true' ]]; then
        echo "[Skip stages: ${SKIPPED_STEPS[*]}]"
    fi
}

#######################################
# START
#######################################
get_req_files

. "${COMMON_FILE}"
. "${VAR_FILE}"


write_log() {
    log "${@}" "${MFA_OUTPUT_FILE}"
}

#######################################
# Check OS version 
#######################################
OS_INFO=$( get_os_info )
if [[ -z "${OS_INFO}" ]]; then
    write_log "Unknown OS version"
    exit $ERR_UNKNOWN_OS
fi

VERSION_CODE=$( get_supported_os_code "${OS_INFO}" "${VER_FILE}" )
if [[ -z "${VERSION_CODE}" ]]; then
    write_log "Unsupported OS version: ${OS_INFO}"
    exit $ERR_UNSUPPORTED_OS
fi

#######################################
# Show WELCOME
#######################################
if [ -f "${LOGO_FILE}" ]; then
    cat "${LOGO_FILE}"
fi

echo -e "\n\n Self Service Portal for Linux Installer"
echo -e " Copyright (c) ${CUR_YEAR} MultiFactor"
echo " Release: ${OS_INFO}"
echo " Version: ${SCRIPT_VERSION}"
echo " ----------------------------------------------------"
display_opts

sleep 1

NOW=$(date +'%d.%m.%Y %H:%M:%S')
echo "Starting at ${NOW}. Release: ${OS_INFO}. Version code: ${VERSION_CODE}" > "${MFA_OUTPUT_FILE}"

#######################################
# Download dependencies 
#######################################
write_log "\nGetting required modules"
get_dependencies

#######################################
# Download modules 
#######################################
MODULES_DIR="${MFA_SCRIPT_DIR}/modules"
sudo mkdir -p "${MODULES_DIR}"
sudo chmod 777 "${MODULES_DIR}"
mark_as_trash "${MODULES_DIR}"

MODULES=()

get_modules() {
    for mod_file in $(sudo cat < "${PIPELINE_FILE}"); do 
        local skipped
        skipped=$( arr_contains_element "${mod_file}" "${SKIPPED_STEPS[@]+"${SKIPPED_STEPS[@]}"}" )
        if [[ -n "${skipped}" ]]; then
            continue
        fi  

        local f_dst="${MODULES_DIR}/${mod_file}.sh"
        if [[ -f "${f_dst}" ]] && [[ "${FORCE_MODE}" == 'false' ]]; then
            MODULES=( "${MODULES[@]+"${MODULES[@]}"}" "${f_dst}" )
            mark_as_trash "${f_dst}"
            continue
        fi

        repo_path=$( get_repo_path )
        local f_src="${repo_path}/modules/${VERSION_CODE}/${mod_file}.sh"
        try_download "${f_src}" "${f_dst}"
        
        check_file_exists "${f_dst}"
        sudo chmod -x "${f_dst}"

        MODULES=( "${MODULES[@]+"${MODULES[@]}"}" "${f_dst}" )
        mark_as_trash "${f_dst}"
    done
}
get_modules

sudo chmod 700 -R "$MFA_SCRIPT_DIR"

#######################################
# Run modules
#######################################
run_modules() {
    for mod_file in "${MODULES[@]+"${MODULES[@]}"}"; do 
        check_file_exists "${mod_file}"

        . "${mod_file}"
        assert_success
    done
}
run_modules

write_log "\nSelf Service Portal installed successfully\n"

exit 0