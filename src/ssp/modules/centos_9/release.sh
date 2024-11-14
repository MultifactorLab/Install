#!/usr/bin/env bash

write_log "\nInstalling application components"

{
    sudo dnf install -y wget
} &>> "${MFA_OUTPUT_FILE}"
assert_success

write_log " - Downloading Self Service Portal release..."
{  
    sudo wget "https://downloader.disk.yandex.ru/disk/0375f6b65448bd363b52459b45138417afae25578dbe9d43750caf6ffd55f7cc/67360ab3/c2y8BafgF3VYZyUe2G6EKXD9Isu-GKlVD73n8uqH4q2PvKq3Czvf07spCPndU0hGsCnBziylVVWh2EoP5NWoxw%3D%3D?uid=0&filename=MultiFactor.SelfService.Linux.Portal_8.2%20%281%29.zip&disposition=attachment&hash=QkBZqIFvjrmzeS6J6F81VA6emfQAVF43xYXo58JElzwqbnaxJbnO73Fjxg8Kdq2Iq/J6bpmRyOJonT3VoXnDag%3D%3D&limit=0&content_type=application%2Fzip&owner_uid=333588736&fsize=3720342&hid=c5f4fcbfda39d5b5dcc7571521b6da94&media_type=compressed&tknv=v2"
} &>> "${MFA_OUTPUT_FILE}"
assert_success

{
    sudo dnf install -y unzip
} &>> "${MFA_OUTPUT_FILE}"
assert_success

write_log " - Extracting files..."
{  
    sudo unzip -o MultiFactor.SelfService.Linux.Portal.zip -d "$MFA_APP_DIR"
    sudo rm MultiFactor.SelfService.Linux.Portal.zip
} &>> "${MFA_OUTPUT_FILE}"
assert_success