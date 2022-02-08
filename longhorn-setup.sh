#!/bin/sh

cd /vagrant
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/master/deploy/longhorn.yaml
kubectl create -f pvc.yaml
kubectl create -f pod.yaml

/bin/false

while [ $? -ne 0 ]; do
  kubectl get pvc | grep Bound
done

kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass longhorn -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo Longhorn volume \"pvc\" created successfully.
