#!/bin/bash -e

on_chroot << EOF

#disable swap, disable bluetooth on mini-uart
systemctl disable dphys-swapfile
systemctl disable hciuart

# disable 3rd party software
systemctl disable noderedrevpinodes-server
systemctl disable revpipyload

systemctl set-default multi-user.target

# peg cpu at 1200 MHz to maximize spi0 throughput and avoid jitter
/usr/bin/revpi-config enable perf-governor
EOF

rm "$ROOTFS_DIR/var/lib/apt/lists/"*Packages

if [ "$(/bin/ls pkgs/*.deb 2>/dev/null)" ] ; then
	mkdir -p "${ROOTFS_DIR}/tmp/pkgs-2"
	mount --bind "pkgs" "${ROOTFS_DIR}/tmp/pkgs-2"
	on_chroot  << EOF
dpkg -i /tmp/pkgs-2/*.deb
EOF
fi

# remove logs and ssh host keys
find "$ROOTFS_DIR/var/log" -type f -delete
find "$ROOTFS_DIR/etc/ssh" -name "ssh_host_*_key*" -delete

on_chroot << EOF
apt update
EOF
