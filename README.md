# Basics

## Install uwsm if the uwsm session crashes on login

## Set default sudoers editor (to automate)
Defaults editor=/usr/bin/nano

## Set sudo timeout  (to automate)
sudo EDITOR=nano visudo

Modify line with "Defaults env_rest" or add at the end of the file timestamp_timeout=mins or -1 for reboot timeout

## install nvidia-settings for thermals and other useless stuff

## sudo pacman -Sy archlinux-keyring

## GRUB and os-prober
- Install os-prober
- Edit the GRUB configuration file:
sudo nano /etc/default/grub
GRUB_DISABLE_OS_PROBER=false
- Regenerate GRUB config
sudo grub-mkconfig -o /boot/grub/grub.cfg

## Uninstall package and dependencies
sudo pacman -Rns package_name
    -R: uninstall package
    -n: related config files
    -s: uninstall orphan dependencies

### from arch wiki
sudo pacman -Qdtq | pacman -Rns

## setting datetime for dual boot (to fix)
timedatectl set-local-rtc 1 (on linux)

# Greeter (sddm with qt6)
theme dir
/usr/share/sddm/themes/

logs
journalctl -u -b sddm