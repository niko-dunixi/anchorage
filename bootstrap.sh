#!/usr/bin/env bash
cd "$(dirname ${0})"
set -euxo pipefail
# pipe_dir="$(mktemp -d)"
# mkfifo "${pipe_dir}/pipe.in" "${pipe_dir}/pipe.out"
# echo "${pipe_dir}/pipe.in" | pbcopy
# function cleanup {
#     rm -rfv "${pipe_dir}"
# }
# trap cleanup EXIT

qemu-system-x86_64 \
  -m 8G \
  -drive file=./out/linux.iso,index=0,media=cdrom \
  -drive file=./out/cloud-init.iso,index=1,media=cdrom \
  -drive file=./out/main.img,if=virtio \
  -net user,hostfwd=tcp::10022-:22 \
  -net nic &

function qemu-ssh {
  ssh -q -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" -p 10022 root@localhost ${@}
}

until qemu-ssh exit; do
  sleep 1s
done
clear
echo "CONNECTED!"
# Format and install archlinux
# qemu-ssh "printf 'gn\n\n\nw' | fdisk /dev/vda"
qemu-ssh "mkfs.ext4 /dev/vda"
qemu-ssh "mount /dev/vda /mnt"
qemu-ssh "pacstrap /mnt base docker linux linux-firmware"

while qemu-ssh exit; do
  qemu-ssh
done
wait
