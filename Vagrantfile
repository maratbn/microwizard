# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'bento/centos-7.1'

  config.vm.network :private_network, ip: '192.168.22.10'
  config.vm.network :forwarded_port, guest: 3000, host: 3000 # Lobsters
  config.vm.network :forwarded_port, guest: 3306, host: 3306 # MariaDB/MySQL

  config.vm.provider :virtualbox do |vb|
    vb.gui = false
    vb.memory = '2048'
    # vb.customize ['modifyvm', :id, '--nictype1', 'virtio']
    # vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    # vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
  end

  config.vm.provision :shell, path: 'provisioning/scripts/bootstrap.bash'

  config.vm.provision :ansible do |ansible|
    ansible.playbook = 'provisioning/microwizard.yml'
    ansible.extra_vars = {
      ansible_ssh_user: 'vagrant'
    }
  end
end