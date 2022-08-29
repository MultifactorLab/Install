#!/usr/bin/env bash

write_log "\nConfiguring SSL"
{
    sudo apt install -y certbot python3-certbot-nginx
} &>> "${MFA_OUTPUT_FILE}"
assert_success

email=$( get_required_input "   Enter email for alerting about problems with the SSL sertificate" )

{
    sudo certbot --nginx --non-interactive --agree-tos --expand -d ${site_dns} --email ${email}
} &>> "${MFA_OUTPUT_FILE}"
assert_success

write_log "   SSP liveness check link: https://${site_dns}/api/ping"
