# MultifactorLab Products Installers

## Self Service Portal

### 1. Get installer script:

<details><summary><b>Debian/Ubuntu</b></summary>

  ```sh
  sudo mkdir -p /opt/temp/ssp-installer && sudo chmod a+w /opt/temp/ssp-installer
  wget -q -O /opt/temp/ssp-installer/install.sh https://raw.githubusercontent.com/MultifactorLab/Install/main/src/ssp/install.sh
  sudo chmod +x /opt/temp/ssp-installer/install.sh
  ```
</details>

### 2. Run script:
```sh
/opt/temp/ssp-installer/install.sh
```
Installation logs are here: `/opt/temp/ssp-installer/install-log.txt`

### 3. Edit `appsettings.production.xml` file:
```sh
sudo vi /opt/multifactor/ssp/app/appsettings.production.xml
```
Make your changes then press `ESC` and type `:wq` to save file.

### 4. Restart service:
```sh
sudo systemctl restart ssp.service
```
