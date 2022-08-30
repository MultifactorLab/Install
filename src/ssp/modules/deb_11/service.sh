#!/usr/bin/env bash

write_log "\nCreating a service"
write_log " - Setting up service config files"

SERVIE_FILE="/etc/systemd/system/${MFA_SSP_SERVICE_FILE}"

sudo chmod -R a+rw /etc/systemd/system/
sudo cat "${MFA_SCRIPT_DIR}/templates/service" > "${SERVIE_FILE}"

sudo sed -i "s:__working_dir__:$MFA_APP_DIR:g" "${SERVIE_FILE}"
sudo sed -i "s:__dll__:${MFA_SSP_DLL_PATH}:g" "${SERVIE_FILE}"
sudo sed -i "s/__user__/${MFA_USER_NAME}/g" "${SERVIE_FILE}"

write_log " - Starting service..."
{
    sudo systemctl enable ssp.service
} &>> "${MFA_OUTPUT_FILE}"
assert_success

{
    sudo systemctl start ssp.service
} &>> "${MFA_OUTPUT_FILE}"
assert_success
