# to make sure the nodes are created in order, we have to force a --no-parallel execution.
ENV['VAGRANT_NO_PARALLEL'] = 'yes'

require 'ipaddr'

number_of_server_nodes  = 3
number_of_agent_nodes   = 2
first_server_node_ip    = '10.11.0.101'
first_agent_node_ip     = '10.11.0.201'

server_node_ip_address  = IPAddr.new first_server_node_ip
agent_node_ip_address   = IPAddr.new first_agent_node_ip

Vagrant.configure(2) do |config|
  config.vm.box = "generic/ubuntu2004"

  config.vm.provider 'libvirt' do |lv, config|
    lv.cpus = 2
    lv.cpu_mode = 'host-passthrough'
    lv.nested = true
    lv.keymap = 'en-us'
    config.vm.synced_folder '.', '/vagrant', type: 'nfs', nfs_version: '4.2', nfs_udp: false
  end

  (1..number_of_server_nodes).each do |n|
    name = "s#{n}"
    fqdn = "#{name}.k3slab.local"
    ip_address = server_node_ip_address.to_s; server_node_ip_address = server_node_ip_address.succ

    config.vm.define name do |config|
      config.vm.provider 'libvirt' do |lv, config|
        lv.memory = 2048
      end

      config.vm.hostname = fqdn
      config.vm.network :private_network, ip: ip_address, libvirt__forward_mode: 'none', libvirt__dhcp_enabled: false
      config.vm.provision 'hosts' do |hosts|
        hosts.autoconfigure = true
        hosts.sync_hosts = true
        hosts.add_localhost_hostnames = false
      end

      # Setup SSH key for authentication
      config.vm.provision 'shell', path: 'setup-ssh-pubkey.sh'
      config.vm.provision 'shell', path: 'preserve-ssh-hostkeys.sh'

      # First master node gets a different setup script than subsequent ones
      if n == 1
        config.vm.provision 'shell', path: 'provision-first-master.sh'
        config.vm.provision 'shell', inline: "cp -f /var/lib/rancher/k3s/server/node-token /vagrant/token.txt"
      else
        config.vm.provision 'shell', path: 'provision-other-masters.sh', args: [first_server_node_ip]
      end

      # Setup distributed block storage after final node finishes provisioning
      if n == number_of_server_nodes
        config.vm.provision 'shell', path: 'longhorn-setup.sh'
        #config.vm.provision 'shell', path: 'portainer-setup.sh'
        config.vm.provision 'shell', path: 'dashboard-setup.sh'
      end
    end
  end

  (1..number_of_agent_nodes).each do |n|
    name = "a#{n}"
    fqdn = "#{name}.k3slab.local"
    ip_address = agent_node_ip_address.to_s; agent_node_ip_address = agent_node_ip_address.succ

    config.vm.define name do |config|
      config.vm.provider 'libvirt' do |lv, config|
        lv.memory = 2048
      end

      config.vm.hostname = fqdn
      config.vm.network :private_network, ip: ip_address, libvirt__forward_mode: 'none', libvirt__dhcp_enabled: false
      config.vm.provision 'hosts' do |hosts|
        hosts.autoconfigure = true
        hosts.sync_hosts = true
        hosts.add_localhost_hostnames = false
      end

      # Setup SSH key for authentication
      config.vm.provision 'shell', path: 'setup-ssh-pubkey.sh'
      config.vm.provision 'shell', path: 'preserve-ssh-hostkeys.sh'

      # Install k3s agent
      config.vm.provision 'shell', path: 'provision-agents.sh', args: [first_server_node_ip]
    end
  end
end

