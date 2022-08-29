# MultifactorLab Products Installers

## Self Service Portal
Get installer script:
```
sudo mkdir -p /opt/temp/ssp-installer && sudo chmod a+w /opt/temp/ssp-installer
wget -q -O /opt/temp/ssp-installer/install.sh https://raw.githubusercontent.com/MultifactorLab/Install/main/src/ssp/install.sh
sudo chmod +x /opt/temp/ssp-installer/install.sh
```
Run script:
```
/opt/temp/ssp-installer/install.sh
```

Installation logs are here: `/opt/temp/ssp-installer/install-log.txt`
