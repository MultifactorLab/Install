#!/usr/bin/env bash

write_log "\nSetting up user"
write_log " - Creating user '${MFA_USER_NAME}'..."
{
    # Check if user not exists then create it.
    if ! id -u "${MFA_USER_NAME}" &>/dev/null; then
        sudo useradd -m -s /bin/bash "${MFA_USER_NAME}"
    fi
} &>> "${MFA_OUTPUT_FILE}"
assert_success

write_log " - Applying permissions..."
{
    sudo chown -R "${MFA_USER_NAME}:${MFA_USER_NAME}" "${MFA_WORK_DIR}"
} &>> "${MFA_OUTPUT_FILE}"
assert_success

{ 
    sudo chmod -R 700 "${MFA_WORK_DIR}"
} &>> "${MFA_OUTPUT_FILE}"
assert_success