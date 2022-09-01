#!/usr/bin/env bash

write_log "\nInstalling and setting up nginx"
write_log " - Installing packages..."
{
    sudo apt-get install -y nginx
} &>> "${MFA_OUTPUT_FILE}"
assert_success

write_log " - Starting nginx..."
{
    sudo service nginx start
} &>> "${MFA_OUTPUT_FILE}"
assert_success

sudo chmod a+rw /etc/nginx/sites-available/

SITE_FILE="/etc/nginx/sites-available/${MFA_SSP_NGINX_FILE}"
write_log " - Configuring server..."
{
    sudo cat "${MFA_SCRIPT_DIR}/templates/nginx" > "${SITE_FILE}"
} &>> "${MFA_OUTPUT_FILE}"
assert_success

site_dns=$( get_input "   Enter your SSP server Domain Name" 1 )

sudo sed -i "s/__dns__/${site_dns}/g" "${SITE_FILE}"
sudo ln -sf "${SITE_FILE}" /etc/nginx/sites-enabled/ssp

sudo systemctl reload nginx
