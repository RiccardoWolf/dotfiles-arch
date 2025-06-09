# Basics

## Install uwsm if the uwsm session crashes on start

## Set default sudoers editor (automate)
Defaults editor=/usr/bin/nano


## Set sudo timeout  (automate)
sudo EDITOR=nano visudo

Modify line with "Defaults env_rest" or add at the end of the file timestamp_timeout=mins or -1 for reboot timeout

## install nvidia-settings for thermals

## sudo pacman -Sy archlinux-keyring

## GRUB os-prober
- Install os-prober
- Edit the GRUB configuration file:
sudo nano /etc/default/grub
GRUB_DISABLE_OS_PROBER=false
- Regenerate GRUB config
sudo grub-mkconfig -o /boot/grub/grub.cfg

## Uninstall wofi and dependencies
sudo pacman -Rns package_name
    -R: uninstall package
    -n: related config files
    -s: uninstall orphan dependencies

### from arch wiki
sudo pacman -Qdtq | pacman -Rns -

## setting datetime for dual boot
timedatectl set-local-rtc 1 (on linux)

# Greeter (sddm-qt6)
theme dir
/usr/share/sddm/themes/

read service file
grep ExecStart /usr/lib/systemd/system/sddm.service

modify it to exec sddm-greeter-qt6 instead of sddm
