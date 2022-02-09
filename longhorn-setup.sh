#!/bin/sh

cd /vagrant
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/master/deploy/longhorn.yaml
kubectl create -f pvc.yaml
kubectl create -f pod.yaml
echo "Waiting for longhorn volume to stabilize..."

# Prime the pump for our while loop...
/bin/false

while [ $? -ne 0 ]; do
  sleep 1s
  kubectl get pvc | grep Bound > /dev/null
done

echo Longhorn volume \"pvc\" created successfully.

kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass longhorn -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo "Longhorn storage class set as default."
