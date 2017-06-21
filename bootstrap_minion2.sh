sudo yum -y install wget

#need to check the java version if fails
sudo wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm"
sudo yum -y localinstall jdk-8u131-linux-x64.rpm

sudo touch /etc/yum.repos.d/virt7-docker-common-release.repo && sudo chmod 777 /etc/yum.repos.d/virt7-docker-common-release.repo
echo "[virt7-docker-common-release]
name=virt7-docker-common-release
baseurl=http://cbs.centos.org/repos/virt7-docker-common-release/x86_64/os/
gpgcheck=0" >> /etc/yum.repos.d/virt7-docker-common-release.repo
#Install Kubernetes, etcd and flannel on all hosts
sudo yum -y install --enablerepo=virt7-docker-common-release kubernetes etcd flannel
#Add master and node to /etc/hosts on all machines
sudo chmod 777 /etc/hosts
echo "192.168.121.9    centos-master
192.168.121.65    centos-minion-1
192.168.121.66  centos-minion-2
192.168.121.67  centos-minion-3" >> /etc/hosts
#Edit /etc/kubernetes/config which will be the same on all hosts
sudo sed -i 's/127.0.0.1/centos-master/g' /etc/kubernetes/config
#Disable the firewall
sudo setenforce 0

echo "##############################################################"
echo "##############################################################"
echo "##############################################################"
echo "##############################################################"
echo "##############################################################"

echo "#################Edit /etc/kubernetes/kubelet#############"
sudo sed -i 's/KUBELET_ADDRESS="--address=127.0.0.1"/KUBELET_ADDRESS="--address=0.0.0.0"/g' /etc/kubernetes/kubelet
sudo sed -i 's/KUBELET_API_SERVER="--api-servers=http:\/\/127.0.0.1:8080"/KUBELET_API_SERVER="--api-servers=http:\/\/centos-master:8080"/g' /etc/kubernetes/kubelet
sudo sed -i 's/KUBELET_HOSTNAME="--hostname-override=127.0.0.1"/KUBELET_HOSTNAME="--hostname-override=centos-minion-2"/g' /etc/kubernetes/kubelet
echo "###########Configure flannel to overlay Docker network in /etc/sysconfig/flanneld#############"
sudo sed -i 's/FLANNEL_ETCD_ENDPOINTS="http:\/\/127.0.0.1:2379"/FLANNEL_ETCD_ENDPOINTS="http:\/\/centos-master:2379"/g' /etc/sysconfig/flanneld
sudo sed -i 's/FLANNEL_ETCD_PREFIX="\/atomic.io\/network"/FLANNEL_ETCD_PREFIX="\/kube-centos\/network"/g' /etc/sysconfig/flanneld
sudo sh -c 'for SERVICES in kube-proxy kubelet flanneld docker; do
    systemctl restart $SERVICES
    systemctl enable $SERVICES
    systemctl status $SERVICES
done'
sudo kubectl config set-cluster default-cluster --server=http://centos-master:8080
sudo kubectl config set-context default-context --cluster=default-cluster --user=default-admin
sudo kubectl config use-context default-context

echo "#####################end with minion2#########################"
echo "##############################################################"
echo "##############################################################"
echo "##############################################################"
echo "##############################################################"
echo "##############################################################"
echo "###################starting the minion3#######################"
