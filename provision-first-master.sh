#!/bin/sh

curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_START=true sh -
rm -rf /var/lib/rancher
mkdir -p /etc/rancher/k3s
echo "cluster-init: true" > /etc/rancher/k3s/config.yaml
systemctl start k3s
cat /var/lib/rancher/k3s/server/node-token
echo Finished provisioning first master node
# Copy node token for next step
