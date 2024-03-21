#!/bin/bash

set -e
set -x

ln -sf /usr/share/zoneinfo/Europe/Sofia /etc/localtime
hwclock --systohc

echo 'archlinux' > /etc/hostname

sed -i -e 's/^#\(en_US.UTF-8\)/\1/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

mkinitcpio -P

echo -e 'haha!strongpassword\nhaha!strongpassword' | passwd
useradd -m -U dev
echo -e 'haha!strongpassword\nhaha!strongpassword' | passwd dev
cat <<EOF > /etc/sudoers.d/dev
Defaults:dev !requiretty
dev ALL=(ALL) NOPASSWD: ALL
EOF
chmod 440 /etc/sudoers.d/dev

mkdir -p /etc/systemd/network
ln -sf /dev/null /etc/systemd/network/99-default.link

systemctl enable sshd
systemctl enable "dhcpcd@$(ip -o l | grep -v ' lo:' | head -n 1 | cut -d\  -f2 | cut -d: -f1)"
systemctl enable qemu-guest-agent

grub-install ${device} # TODO
sed -i -e 's/^GRUB_TIMEOUT=.*$/GRUB_TIMEOUT=1/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
exit