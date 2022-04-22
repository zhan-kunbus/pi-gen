#!/bin/bash -e

on_chroot << EOF
# install nodejs and nodered with an install script and revpi-nodes from npm repository
NODEREDSCRIPT="/tmp/update-nodejs-and-nodered.sh"
/usr/bin/curl -sL \
	https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered\
	--output "$NODEREDSCRIPT"
chmod 755 "$NODEREDSCRIPT"
/usr/bin/sudo -u pi $NODEREDSCRIPT --confirm-install --confirm-pi
rm "$NODEREDSCRIPT"
/usr/bin/sudo -u pi /usr/bin/npm install --prefix /home/pi/.node-red node-red-contrib-revpi-nodes

systemctl disable logiclab
systemctl disable nodered
EOF

if [ "$(/bin/ls pkgs/*.deb 2>/dev/null)" ] ; then
	mkdir -p "${ROOTFS_DIR}/tmp/pkgs-4"
	mount --bind "pkgs" "${ROOTFS_DIR}/tmp/pkgs-4"
	on_chroot << EOF
dpkg -i /tmp/pkgs-4/*.deb
EOF
fi
