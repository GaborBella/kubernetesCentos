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

echo "###################Edit /etc/etcd/etcd.conf#############"
sudo sed -i 's/ETCD_LISTEN_CLIENT_URLS="http:\/\/localhost:2379"/ETCD_LISTEN_CLIENT_URLS="http:\/\/0.0.0.0:2379"/g' /etc/etcd/etcd.conf
sudo sed -i 's/ETCD_ADVERTISE_CLIENT_URLS="http:\/\/localhost:2379"/ETCD_ADVERTISE_CLIENT_URLS="http:\/\/0.0.0.0:2379"/g' /etc/etcd/etcd.conf
echo "################Edit /etc/kubernetes/apiserver##############"
sudo sed -i 's/KUBE_API_ADDRESS="--insecure-bind-address=127.0.0.1"/KUBE_API_ADDRESS="--address=0.0.0.0"/g' /etc/kubernetes/apiserver
sudo sed -i 's/# KUBE_API_PORT="--port=8080"/KUBE_API_PORT="--port=8080"/g' /etc/kubernetes/apiserver
sudo sed -i 's/# KUBELET_PORT="--kubelet-port=10250"/KUBELET_PORT="--kubelet-port=10250"/g' /etc/kubernetes/apiserver
sudo sed -i 's/KUBE_ETCD_SERVERS="--etcd-servers=http:\/\/127.0.0.1:2379"/KUBE_ETCD_SERVERS="--etcd-servers=http:\/\/centos-master:2379"/g' /etc/kubernetes/apiserver
echo "#############Start ETCD and configure it to hold the network overlay###############"
sudo systemctl start etcd
sudo etcdctl mkdir /kube-centos/network
sudo etcdctl mk /kube-centos/network/config "{ \"Network\": \"172.30.0.0/16\", \"SubnetLen\": 24, \"Backend\": { \"Type\": \"vxlan\" } }"
echo "#################Configure flannel to overlay Docker network in /etc/sysconfig/flanneld################"
sudo sed -i 's/FLANNEL_ETCD_ENDPOINTS="http:\/\/127.0.0.1:2379"/FLANNEL_ETCD_ENDPOINTS="http:\/\/centos-master:2379"/g' /etc/sysconfig/flanneld
sudo sed -i 's/FLANNEL_ETCD_PREFIX="\/atomic.io\/network"/FLANNEL_ETCD_PREFIX="\/kube-centos\/network"/g' /etc/sysconfig/flanneld
echo "#############Start the appropriate services#############"
sudo sh -c 'for SERVICES in etcd kube-apiserver kube-controller-manager kube-scheduler flanneld; do
    systemctl restart $SERVICES
    systemctl enable $SERVICES
    systemctl status $SERVICES
done'
echo "######################end with master#########################"
echo "##############################################################"
echo "##############################################################"
echo "##############################################################"
echo "##############################################################"
echo "##############################################################"
echo "###################starting the minion1#######################"
