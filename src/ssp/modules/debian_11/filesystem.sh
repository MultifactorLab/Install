#!/usr/bin/env bash

write_log "\nSetting up directories"
{
    sudo mkdir -p "${MFA_PARENT_DIR}" "${MFA_WORK_DIR}" "${MFA_APP_DIR}" "${MFA_LOG_DIR}" "${MFA_KEY_STOR_DIR}"
} &>> "${MFA_OUTPUT_FILE}"
assert_success