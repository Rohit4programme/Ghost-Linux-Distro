#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="ghost-linux"
iso_label="GHOST_LINUX_$(date +%Y%m)"
iso_publisher="Ghost-Linux Project <https://github.com/ghost-linux/ghost-linux>"
iso_application="Ghost-Linux Next-Gen Linux Live/Installation CD"
iso_version="$(date +%Y.%m.%d)"
install_dir="ghost-linux"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-ia32.grub.esp' 'uefi-x64.grub.esp' 'uefi-ia32.grub.eltorito' 'uefi-x64.grub.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-no-atoms' '-no-xattrs')
file_permissions=(
  ["/etc/shadow"]="0:0:0400"
  ["/etc/gshadow"]="0:0:0400"
  ["/etc/sudoers.d"]="0:0:0750"
  ["/root"]="0:0:0750"
  ["/root/.automated_script.sh"]="0:0:0755"
  ["/usr/local/bin/choose-mirror"]="0:0:0755"
  ["/usr/local/bin/ghost-linux-install"]="0:0:0755"
  ["/usr/local/bin/ghost-linux-driver-detect"]="0:0:0755"
)
