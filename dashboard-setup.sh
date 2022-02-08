cd /vagrant

GITHUB_URL=https://github.com/kubernetes/dashboard/releases
VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S ${GITHUB_URL}/latest -o /dev/null | sed -e 's|.*/||')
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml
kubectl create -f dashboard.admin-user.yml -f dashboard.admin-user-role.yml
kubectl -n kubernetes-dashboard describe secret admin-user-token | grep '^token'
