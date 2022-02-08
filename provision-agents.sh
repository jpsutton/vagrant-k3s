#!/bin/sh

token=$(cat /vagrant/token.txt | tr -d '\n')
first_node_ip=${1}
curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_START=true sh -s agent
rm -rf /var/lib/rancher
mkdir -p /etc/rancher/k3s
echo "token: \"$token\"\nserver: \"https://$first_node_ip:6443\"" > /etc/rancher/k3s/config.yaml
systemctl start k3s-agent
