# MultifactorLab Products Installers

## Self Service Portal
### 1. Get installer script:
```
sudo mkdir -p /opt/temp/ssp-installer && sudo chmod a+w /opt/temp/ssp-installer
wget -q -O /opt/temp/ssp-installer/install.sh https://raw.githubusercontent.com/MultifactorLab/Install/main/src/ssp/install.sh
sudo chmod +x /opt/temp/ssp-installer/install.sh
```
### 2. Run script:
```
/opt/temp/ssp-installer/install.sh
```
Installation logs are here: `/opt/temp/ssp-installer/install-log.txt`

### 3. Edit `appsettings.production.xml` file:
```
sudo vi /opt/multifactor/ssp/app/appsettings.production.xml
```
Make your changes then press `ESC` and type `:qw` to save file.

### 4. Retart service:
```
sudo systemctl restart ssp.service
```