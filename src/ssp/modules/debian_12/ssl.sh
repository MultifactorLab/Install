#!/usr/bin/env bash

write_log "\nConfiguring SSL"
write_log " - Installing Certbot..."
{
    sudo apt-get update
    sudo apt-get install -y certbot python3-certbot-nginx
} &>> "${MFA_OUTPUT_FILE}"
assert_success

email=$( get_input "   Enter valid email for alerting about problems with the SSL certificate" 1 )

write_log " - Getting certificate..."
{
    sudo certbot --nginx \
        --non-interactive \
        --agree-tos \
        --expand \
        -d "${site_dns}" \
        --email "${email}"
} &>> "${MFA_OUTPUT_FILE}"
assert_success

write_log "   SSP liveness check link: https://${site_dns}/api/ping"