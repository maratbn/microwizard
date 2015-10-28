# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'bento/centos-7.1'

  config.vm.network :private_network, ip: "192.168.22.10"
  config.vm.network :forwarded_port, guest: 3000, host: 3000

  config.vm.synced_folder 'docker/', '/microwizard/docker/images'

  config.vm.provider :virtualbox do |vb|
    vb.gui = false
    vb.memory = '2048'
  end

  config.vm.provision :file,
                      source: 'files/docker.repo',
                      destination: '/tmp/docker.repo'

  config.vm.provision :shell,
                      path: 'scripts/bootstrap.bash'

  config.vm.provision :ansible do |ansible|
    ansible.playbook = 'ansible/playbook.yml'
    ansible.extra_vars = {
      ansible_ssh_user: 'vagrant'
    }
  end
end