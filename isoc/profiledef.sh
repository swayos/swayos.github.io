#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="swayos"
iso_label="SWAYOS_$(date +%Y%m)"
iso_publisher="SwayOS <https://swayos.github.io>"
iso_application="SwayOS"
iso_version="$(date +%Y.%m.%d)"
install_dir="swayos"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-x64.systemd-boot.esp' 'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="erofs"
airootfs_image_tool_options=('-zlz4hc,12')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
)
