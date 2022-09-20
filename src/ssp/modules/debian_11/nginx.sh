#!/usr/bin/env bash
set -uo pipefail 

write_log "\nInstalling and setting up nginx"
write_log " - Installing packages..."
{
    sudo apt-get install -y nginx
} &>> "${MFA_OUTPUT_FILE}"
assert_success

{
    sudo nginx -t
} &>> "${MFA_OUTPUT_FILE}"

if [[ $( is_success ) == "true" ]]; then
    {
        sudo service nginx start
    } &>> "${MFA_OUTPUT_FILE}"
    assert_success
fi

write_log " - Configuring nginx..."
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

write_log " - Restarting nginx..."

{
    sudo nginx -t
} &>> "${MFA_OUTPUT_FILE}"
assert_success

{
    sudo service nginx start
} &>> "${MFA_OUTPUT_FILE}"
assert_success

sudo systemctl reload nginx
