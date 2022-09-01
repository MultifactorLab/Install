#!/usr/bin/env bash

write_log "\nSetting up environment"
write_log " - Setting up Microsoft package repository..."
# Add the Microsoft package signing key to your list of trusted keys 
# and add the package repository.
{
    wget https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
} &>> "${MFA_OUTPUT_FILE}"
assert_success

{
    sudo dpkg -i packages-microsoft-prod.deb
} &>> "${MFA_OUTPUT_FILE}"
assert_success

{
    rm packages-microsoft-prod.deb
} &>> "${MFA_OUTPUT_FILE}"
assert_success

write_log " - Installing the .NET 6 runtime..."
{
	sudo apt-get update && sudo apt-get install -y aspnetcore-runtime-6.0
} &>> "${MFA_OUTPUT_FILE}"
assert_success