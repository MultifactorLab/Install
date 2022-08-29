#!/usr/bin/env bash
set -uo pipefail 

MFA_USER_NAME="mfa"

MFA_PARENT_DIR="/opt/multifactor"
MFA_WORK_DIR="${MFA_PARENT_DIR}/ssp"
MFA_APP_DIR="${MFA_WORK_DIR}/app"
MFA_LOG_DIR="${MFA_WORK_DIR}/logs"
MFA_KEY_STOR_DIR="${MFA_WORK_DIR}/key-storage"

MFA_SSP_DLL_NAME="MultiFactor.SelfService.Linux.Portal.dll"
MFA_SSP_DLL_PATH="${MFA_APP_DIR}/${MFA_SSP_DLL_NAME}"

MFA_SSP_NGINX_FILE="ssp"
MFA_SSP_SERVICE_FILE="ssp.service"