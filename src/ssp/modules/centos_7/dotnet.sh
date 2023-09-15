#!/usr/bin/env bash

write_log "\nSetting up environment"
write_log " - Setting up Microsoft package repository..."
# Add the Microsoft package signing key to your list of trusted keys 
# and add the package repository.
{
    sudo rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm
} &>> "${MFA_OUTPUT_FILE}"
assert_success

{
    sudo yum makecache
} &>> "${MFA_OUTPUT_FILE}"
assert_success

write_log " - Installing the .NET 6 runtime..."
{
	sudo yum install -y aspnetcore-runtime-6.0
} &>> "${MFA_OUTPUT_FILE}"
assert_success