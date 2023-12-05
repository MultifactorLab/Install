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

<details><summary><b>Centos</b></summary>

  ```sh
  sudo mkdir -p /opt/temp/ssp-installer && sudo chmod a+w /opt/temp/ssp-installer
  yum list installed | grep wget || sudo yum install -y wget
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

## Help

To display version and supported OS use `-i` flag:
```sh
/opt/temp/ssp-installer/install.sh -i
```

To display full help use `-h` flag:
```sh
/opt/temp/ssp-installer/install.sh -h
```

## Release notes

### Version 1.4 | Freedom of Choice
##### New
- You can now skip one or more installation steps. To display all the steps, simply run the script with the `-l` flag.
- Centos 7 support.

### 1.3 | Happy Ubuntoid
##### New
- Ubuntu 20.04 support.