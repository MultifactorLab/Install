#!/usr/bin/env bash

write_log "\nSetting up user"
write_log " - Creating user '${MFA_USER_NAME}'..."
{
    # Check if user not exists then create it.
    id -u "${MFA_USER_NAME}" || sudo useradd "${MFA_USER_NAME}"
} &>> "${MFA_OUTPUT_FILE}"
assert_success

write_log " - Applying permissions..."
{
    sudo chown -R "${MFA_USER_NAME}": "${MFA_WORK_DIR}"
} &>> "${MFA_OUTPUT_FILE}"
assert_success

{ 
    sudo chmod -R 700 "${MFA_WORK_DIR}"
} &>> "${MFA_OUTPUT_FILE}"
assert_success
