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

