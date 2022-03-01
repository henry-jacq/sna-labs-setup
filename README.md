# SNA Labs Setup for Linux

<p align="center">
<a href="https://github.com/henry-jacq/sna-labs-setup" rel="nofollow"><img src="https://img.shields.io/badge/version-2.00-red.svg" style="max-width:100%;"></a>
<a href="https://github.com/henry-jacq/sna-labs-setup" rel="nofollow"><img src="https://img.shields.io/badge/status-beta-brightgreen.svg" style="max-width:100%;"></a>

 
  
  This Tool is useful for others who wants to configure lab setup on their linux (Host) machines easily.
  
> This is a multi-use bash script for Linux machines to connect to [selfmade ninja labs](https://labs.selfmade.ninja).
 
>Note:-
>  This script is still under development. If you found any issues, please open a [issue](https://github.com/henry-jacq/sna-labs-setup/issues) in our repo or       contribute your code to make this code even better. For now use the script under old folder.
 
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
| -f or --force| This mode runs the script in force mode by this if any existing files related to wireguard and ssh keys are deleted or overwrited |
| -i or --interactive | This mode allows the user to interact with a shell and do what they want. |
| -h or --help | print the help message to the user. |
| -v or --version | Prints the version number. |
