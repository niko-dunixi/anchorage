#!/usr/bin/env bash
set -euxo pipefail
function is-command {
  hash ${@} &>/dev/null
}

if is-command brew; then
  brew bundle --file Brewfile
elif is-command pacman; then
  sudo pacman -Sy --noconfirm \
    aria2 \
    dnsmasq \
    dmidecode \
    expect \
    qemu \
    vde2 \
    virt-manager \
    virt-viewer \
    xorriso
    # bridge-utils \
    # dnsmasq \
    # vde2 \
    # virt-manager \
    # virt-viewer \
    # qemu
  if is-command yay; then
    yay -Sy --noconfirm \
      libguestfs
  elif is-comman yaourt; then
    yaourt -S --needed libguestfs
  fi
fi

# Hack for Darwin
if is-command gsed; then
  function sed {
    gsed ${@}
  }
fi

# libvirt_config_file="/etc/libvirt/libvirtd.conf"
# if [[ $(uname) == "Darwin" ]]; then
#   libvirt_config_file="/usr/local/etc/libvirt/libvirtd.conf"
# fi
# if [ -s "${libvirt_config_file}" ]; then
#   sudo sed -i '/^unix_sock_group\s*=/d' "${libvirt_config_file}"
#   sudo sed -i '/^unix_sock_ro_perms\s*=/d' "${libvirt_config_file}"
#   sudo sed -i '/^unix_sock_rw_perms\s*=/d' "${libvirt_config_file}"
#   sudo sed -i '/^unix_sock_admin_perms\s*=/d' "${libvirt_config_file}"
#   sudo sed -i '/^unix_sock_dir\s*=/d' "${libvirt_config_file}"
#   tmp_config="$(mktemp)"
# fi
# cat <<EOCONFIG >> "${tmp_config}"
# unix_sock_group = "libvirt"
# unix_sock_rw_perms = "0770"
# EOCONFIG
# cat "${tmp_config}" | sudo tee -a "${libvirt_config_file}"
# unset tmp_config

# if is-command usermod; then
#   sudo usermod -aG kvm "${USER}"
# fi

# if is-command systemctl; then
#   sudo systemctl enable libvirtd.service
#   sudo systemctl restart libvirtd.service
# fi
