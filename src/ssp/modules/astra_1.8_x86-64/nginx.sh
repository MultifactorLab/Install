#!/usr/bin/env bash
set -uo pipefail 

write_log "\nInstalling and setting up nginx"
write_log " - Installing packages..."
{
    sudo apt-get update
    sudo apt-get install -y nginx
} &>> "${MFA_OUTPUT_FILE}"
assert_success

{
    sudo nginx -t
} &>> "${MFA_OUTPUT_FILE}"

if [[ $( is_success ) == "true" ]]; then
    {
        sudo systemctl start nginx
    } &>> "${MFA_OUTPUT_FILE}"
    assert_success
fi

write_log " - Configuring nginx..."
{
    sudo chmod 644 /etc/nginx/sites-available/
} &>> "${MFA_OUTPUT_FILE}"
assert_success

SITE_FILE="/etc/nginx/sites-available/${MFA_SSP_NGINX_FILE}"
write_log " - Configuring server..."
{
    sudo cp "${MFA_SCRIPT_DIR}/templates/nginx" "${SITE_FILE}"
} &>> "${MFA_OUTPUT_FILE}"
assert_success

site_dns=$( get_input "   Enter your SSP server Domain Name" 1 )

{
    sudo sed -i "s/__dns__/${site_dns}/g" "${SITE_FILE}"
} &>> "${MFA_OUTPUT_FILE}"
assert_success

{
    sudo ln -sf "${SITE_FILE}" /etc/nginx/sites-enabled/ssp
} &>> "${MFA_OUTPUT_FILE}"
assert_success

write_log " - Validating nginx configuration..."
{
    sudo nginx -t
} &>> "${MFA_OUTPUT_FILE}"
assert_success

write_log " - Restarting nginx..."
{
    sudo systemctl restart nginx
} &>> "${MFA_OUTPUT_FILE}"
assert_success

{
    sudo selinux-adjust-nginx || true
    
    sudo ufw allow 'Nginx Full' || true
} &>> "${MFA_OUTPUT_FILE}"