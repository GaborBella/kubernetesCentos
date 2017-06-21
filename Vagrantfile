$script = <<SCRIPT
sudo yum -y update
sudo yum -y install dos2unix\
                    wget
dos2unix bootstrap_master.sh
dos2unix bootstrap_minion1.sh
echo "++++++++++++++READY FOR START+++++++++++++"
SCRIPT

Vagrant.configure(2) do |config|

  config.vm.define "master" do |master|
    master.vm.box = "centos/7"
    master.vm.synced_folder ".", "/vagrant", type: "virtualbox"
    master.vm.network "private_network", ip: "192.168.121.9"
    master.vm.hostname = "centos-master"
    master.vm.provision "shell", inline: $script
    master.vm.provision :shell, path: "bootstrap_master.sh"
    master.vm.provider "virtualbox" do |vb|
       vb.customize ["modifyvm", :id, "--usb","off", "--vram",32, "--hwvirtex", "on"]
       vb.gui = false
       vb.memory = 1024
       vb.cpus = 1
    end
  end

  config.vm.define "minion1" do |cluster1|
  cluster1.vm.box = "centos/7"
  cluster1.vm.synced_folder ".", "/vagrant", type: "virtualbox"
  cluster1.vm.network "private_network", ip: "192.168.121.65"
  cluster1.vm.hostname = "centos-minion1"
  cluster1.vm.provision "shell", inline: $script
  cluster1.vm.provision :shell, path: "bootstrap_minion1.sh"
  cluster1.vm.provider "virtualbox" do |vb|
       vb.customize ["modifyvm", :id, "--usb","off", "--vram",32, "--hwvirtex", "on"]
       vb.gui = false
       vb.memory = 1024
       vb.cpus = 1
    end
  end

  config.vm.define "minion2" do |cluster2|
  cluster2.vm.box = "centos/7"
  cluster2.vm.synced_folder ".", "/vagrant", type: "virtualbox"
  cluster2.vm.network "private_network", ip: "192.168.121.66"
  cluster2.vm.hostname = "centos-minion2"
  cluster2.vm.provision "shell", inline: $script
  cluster2.vm.provision :shell, path: "bootstrap_minion2.sh"
  cluster2.vm.provider "virtualbox" do |vb|
       vb.customize ["modifyvm", :id, "--usb","off", "--vram",32, "--hwvirtex", "on"]
       vb.gui = false
       vb.memory = 1024
       vb.cpus = 1
    end
  end

  config.vm.define "minion3" do |cluster3|
  cluster3.vm.box = "centos/7"
  cluster3.vm.synced_folder ".", "/vagrant", type: "virtualbox"
  cluster3.vm.network "private_network", ip: "192.168.121.67"
  cluster3.vm.hostname = "centos-minion3"
  cluster3.vm.provision "shell", inline: $script
  cluster3.vm.provision :shell, path: "bootstrap_minion3.sh"
  cluster3.vm.provider "virtualbox" do |vb|
       vb.customize ["modifyvm", :id, "--usb","off", "--vram",32, "--hwvirtex", "on"]
       vb.gui = false
       vb.memory = 1024
      vb.cpus = 1
    end
  end

end
