# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
settings = YAML.load_file 'settings.yml'

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.insert_key = false

  config.vm.define "ubuntu-host" do |ubuntu| 
    ubuntu.vm.box = "ubuntu/focal64"
    ubuntu.vm.hostname = "ubuntu.test"
    ubuntu.vm.synced_folder ".", "/vagrant", disabled: true

    # ubuntu.vm.provision :shell do |shell|
    #   shell.path = "https://raw.githubusercontent.com/VasAtanasov/scripts/main/docker.sh"
    # end

    # ubuntu.vm.provision :shell do |shell|
    #   shell.env = { 'CURRENT_USER' => 'vagrant'}
    #   shell.path = "https://raw.githubusercontent.com/VasAtanasov/scripts/main/docker-group.sh"
    # end

    ubuntu.vm.provision :shell do |shell|
      shell.env = { 'JAVA_VERSION' => settings['JAVA_VERSION'], 
                    'MAVEN_VERSION' => settings['MAVEN_VERSION'] }
      shell.path = "sdkman-java-mvn.sh"
      shell.privileged = false
    end

    # ubuntu.vm.provision :shell do |shell|
    #   shell.path = "ufw-setup.sh"
    # end

    ubuntu.vm.provider :virtualbox do |vb|
      vb.name = "ubuntu-test-host"
      vb.memory = 4096
      vb.cpus = 2
      # vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
      # vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
    end 
  end
end
