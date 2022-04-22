#!/bin/bash -e

install -m 644 files/cmdline.txt "${ROOTFS_DIR}/boot/"
install -m 644 files/config.txt "${ROOTFS_DIR}/boot/"
install -m 644 files/revpi-aliases.sh "${ROOTFS_DIR}/etc/profile.d/"
install -m 644 files/rsyslog.conf "${ROOTFS_DIR}/etc/"
install -m 644 files/modules "${ROOTFS_DIR}/etc/"

install -d "${ROOTFS_DIR}/etc/apt/trusted.gpg.d"
install -d "${ROOTFS_DIR}/etc/apt/sources.list.d"
install -m 644 files/revpi.gpg "${ROOTFS_DIR}/etc/apt/trusted.gpg.d/"
install -m 644 files/revpi.list "${ROOTFS_DIR}/etc/apt/sources.list.d/"

# copy piTest source code
PICONTROLDIR=`mktemp -d -p /tmp piControl.XXXXXXXX`
git clone https://github.com/RevolutionPi/piControl $PICONTROLDIR
cp -pr $PICONTROLDIR/piTest "$ROOTFS_DIR/home/pi/demo"
cp -p $PICONTROLDIR/piControl.h "$ROOTFS_DIR/home/pi/demo"
sed -i -r -e 's%\.\./%%' "$ROOTFS_DIR/home/pi/demo/Makefile"
chown -R 1000:1000 "$ROOTFS_DIR/home/pi/demo"
chmod -R a+rX "$ROOTFS_DIR/home/pi/demo"
rm -r $PICONTROLDIR

install -d -m 755 -o root -g root "$ROOTFS_DIR/etc/revpi"
echo ${EXPORT_NAME} > "$ROOTFS_DIR/etc/revpi/image-release"
install -d -m 700 -o 1000 -g 1000 "$ROOTFS_DIR/home/pi/.ssh"

# automatically bring up eth0 and eth1 again after a USB bus reset
sed -i -e '6i# allow-hotplug eth0\n# allow-hotplug eth1\n' "$ROOTFS_DIR/etc/network/interfaces"

# display IP address at login prompt
sed -i -e '1s/$/ \\4 \\6/' "$ROOTFS_DIR/etc/issue"

cat >> "$ROOTFS_DIR/etc/dhcpcd.conf" <<-EOF

	# Prioritize wlan0 routes over eth0 routes.
	interface wlan0
	        metric 100
	EOF

on_chroot << EOF
# As the revpi.list and revpi.gpg added, update is needed.
apt-get update
EOF
