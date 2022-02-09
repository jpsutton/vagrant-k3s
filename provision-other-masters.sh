#!/bin/sh

token=$(cat /vagrant/token.txt | tr -d '\n')
first_node_ip=${1}
curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_START=true sh -
rm -rf /var/lib/rancher
mkdir -p /etc/rancher/k3s
echo "token: \"$token\"\nserver: \"https://$first_node_ip:6443\"" > /etc/rancher/k3s/config.yaml
systemctl start k3s
echo "Waiting for pods to stabilize..."

# Wait until all pods have been created
while [ $? -eq 0 ]; do
  sleep 1s
  kubectl get pods -A | grep ContainerCreating > /dev/null
done

echo Node has stabilized

exit 0
