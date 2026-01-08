#!/bin/bash

vagrant ssh s1 -c "sudo cat /etc/rancher/k3s/k3s.yaml" | sed 's/127.0.0.1/10.11.0.101/g' > k3s.yaml
export KUBECONFIG=$(pwd)/k3s.yaml