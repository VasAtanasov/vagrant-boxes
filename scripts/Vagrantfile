# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
settings = YAML.load_file 'settings.yml'

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.insert_key = false

  config.vm.define "ubuntu-host" do |ubuntu| 
    ubuntu.vm.box = "vasatanasov/ubuntu-dob"
    ubuntu.vm.box_version = "1.1.0"
    ubuntu.vm.hostname = "ubuntu.test"
    ubuntu.vm.synced_folder ".", "/vagrant", disabled: true

    ubuntu.vm.provision :shell do |shell|
      shell.env = { 'JAVA_VERSION' => settings['JAVA_VERSION'], 
                    'MAVEN_VERSION' => settings['MAVEN_VERSION'] }
      shell.path = "sdkman-java-mvn.sh"
      shell.privileged = false
    end

    ubuntu.vm.provider :virtualbox do |vb|
      vb.name = "ubuntu-test-host"
      vb.memory = 4096
      vb.cpus = 2
      vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
      vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
    end 
  end
end
