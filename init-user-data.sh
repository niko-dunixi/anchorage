#!/usr/bin/env bash
cd "$(dirname "${0}")"
set -euxo pipefail

cat > out/user-data <<EOF
#cloud-config
users:
  - name: root
    ssh_authorized_keys:
        - $(cat ${HOME}/.ssh/id_ed25519.pub)
EOF