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
  -display none \
  -m 8G \
  -drive file=./out/linux.iso,index=0,media=cdrom \
  -drive file=./out/cloud-init.iso,index=1,media=cdrom \
  -drive file=./out/main.img,if=virtio \
  -net user,hostfwd=tcp::10022-:22 \
  -net nic &
sleep 10s

function qemu-ssh {
  ssh -q -o ConnectTimeout=3 -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" -p 10022 root@localhost ${@}
}

set +x
printf 'Waiting for SSH to go live (this will take a while)...'
until qemu-ssh exit; do
  printf '.'
done
clear
echo "CONNECTED!"
USERNAME="docker"
HOSTNAME="qemu"
qemu-ssh << EOF
mkfs.ext4 /dev/vda
mount /dev/vda /mnt
pacstrap /mnt base docker linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
echo "${HOSTNAME}" > /etc/hostname
cat > /etc/hosts <<EOHOSTS
127.0.0.1	localhost
::1		localhost
127.0.1.1	${HOSTNAME}.localdomain	${HOSTNAME}
EOHOSTS
cat > /etc/systemd/system/docker.service.d/execstart.conf <<EOCONFIG
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H unix:///var/run/docker.sock -H tcp://0.0.0.0:4243
EOCONFIG
useradd docker-user
usermod -aG docker docker-user
systemctl enable docker.service
exit
shutdown
EOF

wait
