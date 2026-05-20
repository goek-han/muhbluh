#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y wireshark

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

# systemctl enable podman.socket

# install nix
# # from https://fedoraproject.org/wiki/Changes/Nix_package_tool#How_To_Test
# mkdir -p /nix
# dnf5 install -y nix nix-daemon
# systemctl enable nix-daemon

# determinate installer

rm -rf /nix /var/lib/nix 2>/dev/null || true

mkdir -p /etc/ostree
cat >/etc/ostree/prepare-root.conf <<'EOF'
[composefs]
enabled = yes
[root]
transient = true
EOF
rpm-ostree initramfs-etc --track=/etc/ostree/prepare-root.conf

curl -fsSL https://install.determinate.systems/nix | sh -s -- install ostree \
  --no-confirm \
  --explain \
  --persistence=/var/lib/nix \
  --extra-conf "experimental-features = nix-command flakes"

cat >/etc/profile.d/nix.sh <<'EOF'
if [ -e /var/lib/nix/profiles/default/etc/profile.d/nix.sh ]; then
  . /var/lib/nix/profiles/default/etc/profile.d/nix.sh
fi
EOF
chmod +x /etc/profile.d/nix.sh

# install additional dev tools
dnf install -y @development-tools
dnf5 install -y python3-wheel python3-devel python3-netifaces
