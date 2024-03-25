#!/bin/bash

set -e
set -x

if [ -e /dev/vda ]; then
  device=/dev/vda
elif [ -e /dev/sda ]; then
  device=/dev/sda
else
  echo "ERROR: There is no disk available for installation" >&2
  exit 1
fi
export device

memory_size_in_kilobytes=$(free | awk '/^Mem:/ { print $2 }')
swap_size_in_kilobytes=$((memory_size_in_kilobytes * 2))
sfdisk "$device" <<EOF
label: dos
size=512MiB,                       type=EF, bootable
size=${swap_size_in_kilobytes}KiB, type=82
                                   type=83
EOF
mkfs.fat "${device}1"
mkswap "${device}2"
mkfs.ext4 "${device}3"
mount "${device}3" /mnt
mkdir /mnt/boot
mount "${device}1" /mnt/boot
# Get some US mirrors just to install reflector, which will rank the mirrors
# by speed before intalling the rest of the packages
curl -fsS https://raw.githubusercontent.com/snkolev18/packer-arch-proxmox/master/http/mirrorlist > /etc/pacman.d/mirrorlist

#while ! systemctl show pacman-init.service | grep SubState=exited; do
#    systemctl --no-pager status -n0 pacman-init.service || true
#    sleep 1
#done

pacman-key --init
pacman-key --populate
#pacman-key --refresh-keys

# Install base packages, just enough for a basic system
pacman -Sy --noconfirm
pacstrap /mnt base base-devel linux linux-firmware grub openssh sudo qemu-guest-agent dhcpcd python
swapon "${device}2"
genfstab -p /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash

