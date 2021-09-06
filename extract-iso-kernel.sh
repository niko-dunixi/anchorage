#!/usr/bin/env bash
cd "$(dirname "$0")"
[ -f ./out/linux.iso ] || {
  echo "You need to execute 'make out/linux.iso'"
  exit 1
}
set -euxo pipefail
mount_directory="$(mktemp -d)"
function cleanup {
  sudo umount "${mount_directory}"
}
trap cleanup EXIT
sudo mount -o loop ./out/linux.iso "${mount_directory}"
find "${mount_directory}" -type f -iname '*linuz*' -exec cp \{\} ./out/linux-kernel \;
