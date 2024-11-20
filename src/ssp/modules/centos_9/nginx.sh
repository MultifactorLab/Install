#!/usr/bin/env bash
set -uo pipefail 

write_log "\nInstalling and setting up nginx"
write_log " - Installing packages..."

{
    sudo dnf install -y epel-release
} &>> "${MFA_OUTPUT_FILE}"
assert_success

{
    sudo dnf install -y nginx
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

# {
#     sudo chmod a+rw /etc/nginx/sites-available/
# } &>> "${MFA_OUTPUT_FILE}"

SITE_FILE="/etc/nginx/conf.d/${MFA_SSP_NGINX_FILE}.conf"
write_log " - Configuring nginx..."
{
    sudo cat "${MFA_SCRIPT_DIR}/templates/nginx" | sudo tee "${SITE_FILE}" > /dev/null
} &>> "${MFA_OUTPUT_FILE}"
assert_success

site_dns=$( get_input "   Enter your SSP server Domain Name" 1 )

{
    sudo sed -i "s/__dns__/${site_dns}/g" "${SITE_FILE}"
} &>> "${MFA_OUTPUT_FILE}"

{
    sudo setsebool -P httpd_can_network_connect on
} &>> "${MFA_OUTPUT_FILE}"

write_log " - Restarting nginx..."
{
    sudo nginx -t
} &>> "${MFA_OUTPUT_FILE}"
assert_success

{
    sudo systemctl restart nginx
} &>> "${MFA_OUTPUT_FILE}"
assert_success

sudo systemctl reload nginx