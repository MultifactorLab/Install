# MultifactorLab Products Installers

## Self Service Portal

### OS Support

SSP version 1.1.10 was the last release on the platform .NET 6. All releases starting from version 3.0.2 require installation .NET 8, which is not available for some OS versions. The SSP version 1.1.10 will be installed on such OS. Below is the compatibility table, according to which the script installs the portal.

|           | .NET 6 | .NET 8 |
| ----------| ------ |---|
| CentOS 7  | +  | - |
| CentOS 9  | -  | + |
| Debian 11  | +  | - |
| Debian 12  | -  | + |
| Ubuntu 20.04  | -  | + |
| Ubuntu 22.04  | -  | + |

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

To install the latest available version:
```sh
/opt/temp/ssp-installer/install.sh
```

To install a version that supports .NET 6:
```sh
/opt/temp/ssp-installer/install.sh -b dotnet6
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

### Version 1.5 | New day, new dotnet
##### New

- .NET 8 support has been added. .NET 6 support has been retained on some operating systems for which updating is not possible.
- Centos 9 support.
- Debian 12 support.
- Ubuntu 22.04 support.

### Version 1.4 | Freedom of Choice
##### New

- You can now skip one or more installation steps. To display all the steps, simply run the script with the `-l` flag.
- Centos 7 support.

### Version 1.3 | Happy Ubuntoid
##### New

- Ubuntu 20.04 support.
