# vagrant-k3s
Vagrant project to setup a k3s lab cluster. This is my first vagrant project. I used https://github.com/rgl/k3s-vagrant as my starting point.

# Usage
- Clone the git repo and enter the project directory
- Add an SSH public key file to the project directory named "id_rsa.pub" (this will be setup for the "vagrant" user of each node)
- Make sure the required vagrant plugins are installed:
```
vagrant plugin install vagrant-hosts
vagrant plugin install vagrant-libvirt
```
- Bring up the cluster as follows:
```
vagrant up --no-destroy-on-error --no-tty --provider=libvirt
```
- If there are any errors, you can SSH into the troublesome node to investigate. You can get a list of hosts and IP addresses using the following:
```
vagrant hosts list
```
- Once you're ready to tear down the stack, run the following:
```
vagrant destroy -f
```

# Connecting to the Cluster with kubectl

To connect to the cluster from your host machine using kubectl, source the `setup-kubectl.sh` script:

```
source setup-kubectl.sh
```

**Important:** You must use `source` (or `. setup-kubectl.sh`) rather than executing it directly (`./setup-kubectl.sh`). This is because the script sets the `KUBECONFIG` environment variable, which only affects the current shell session when sourced.

After sourcing the script, you can verify the connection:
```
kubectl get nodes
```

The script will:
1. Copy the kubeconfig file from the first server node (s1)
2. Replace `127.0.0.1` with the actual server IP (`10.11.0.101`) so it works from your host
3. Set the `KUBECONFIG` environment variable to point to the local `k3s.yaml` file

Note: The `KUBECONFIG` environment variable is only set for the current shell session. If you open a new terminal, you'll need to source the script again, or manually set `export KUBECONFIG=$(pwd)/k3s.yaml`.

