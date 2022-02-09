#!/bin/sh

dest="/home/vagrant/.ssh/authorized_keys"
cp /vagrant/id_rsa.pub "$dest"
chown vagrant:vagrant "$dest"
chmod 600 "$dest"
sudo mkdir -p /root/.ssh
sudo cp "$dest" /root/.ssh/
sudo chown root:root /root/.ssh/authorized_keys
