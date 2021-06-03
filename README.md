# vagrant-boxes

Download Ubuntu 20.04 iso and install in VirtualBox.

When installation is ready add port forwarding

Execute scripts/vagrant/vagrant.sh vis ssh to insert vagrant user public key

```powershell
  plink.exe -ssh vagrant@localhost -P 3333 -l vagrant -pw vagrant -t -m .\vagrant.sh
```

Package the box with vagrant.
