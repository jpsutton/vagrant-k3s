#!/bin/sh

kubectl apply -n portainer -f https://raw.githubusercontent.com/portainer/k8s/master/deploy/manifests/portainer/portainer-lb.yaml
kubectl apply -n portainer -f https://downloads.portainer.io/portainer-agent-ce211-k8s-lb.yaml
