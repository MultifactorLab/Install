#!/usr/bin/env bash

write_log "\nInstalling application components"
write_log " - Downloading Self Service Portal release..."
{  
    sudo wget https://github.com/MultifactorLab/multifactor-selfservice-portal/releases/download/1.1.10/MultiFactor.SelfService.Linux.Portal.zip
} &>> "${MFA_OUTPUT_FILE}"
assert_success

write_log " - Extracting files..."
{  
    sudo unzip -o MultiFactor.SelfService.Linux.Portal.zip -d "$MFA_APP_DIR"
    sudo rm MultiFactor.SelfService.Linux.Portal.zip
} &>> "${MFA_OUTPUT_FILE}"
assert_success
