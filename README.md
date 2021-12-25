# SNA Labs Setup for Linux

<p align="center">
<a href="https://github.com/henry-jacq/sna-labs-setup" rel="nofollow"><img src="https://img.shields.io/badge/version-1.12-red.svg" style="max-width:100%;"></a>
<a href="https://github.com/henry-jacq/sna-labs-setup" rel="nofollow"><img src="https://img.shields.io/badge/status-beta-brightgreen.svg" style="max-width:100%;"></a>

 
  
  This Tool is useful for others who wants to configure lab setup on their linux machines easily.
  
> This is a multi-use bash script for Linux machines to connect to [selfmade ninja labs](https://labs.selfmade.ninja).
 
>Note:-
>  This script is still under development. If you found any issues, please open a [issue](https://github.com/henry-jacq/sna-labs-setup/issues) in our repo or if want to add a feature to this you can !
 
  - - -

## Software Requirements:

The following OSs are officially supported:

- [Arch Linux](https://archlinux.org) 
- [Debian 10+](https://debian.org)
- [Linux Mint](https://linuxmint.com)
- [Ubuntu 15.10+](https://ubuntu.com)

The following OSs are likely able to run this script:

- Manjaro Linux
- Deepin 15+
- Elementary
- Fedora 22+
  
- - -
## Install Prerequisites
For Debian-based Distributions
```bash
sudo apt install git wireguard wireguard-tools
  ```
For Arch-based Distributions
```bash
sudo pacman -S git wireguard-tools
  ```
OpenSuse
```bash
sudo zypper install git wireguard-tools
  ```
For RedHat-based Distributions
```bash
sudo dnf install git wireguard-tools  
```
  - - -
### Installation
```git clone https://github.com/henry-jacq/sna-labs-setup.git```
   
### For Permissions
```chmod +x *```

### Navigate
```cd sna-labs-setup```
  
### Execution
```sudo ./labs-setup.sh <option>```
  

  
| Arguments | Description |
| --- | --- |
| -f or --force| List all new or modified files |
| -i or --interactive | Show file differences that haven't been staged |
| -h or --help | print the help message |
| -v or --version | Prints the version number |
