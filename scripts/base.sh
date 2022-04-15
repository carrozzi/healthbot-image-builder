#!/usr/bin/env bash
set -x
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.conf
echo "export KUBECONFIG=/var/local/healthbot/k8s.conf" >> /root/.bashrc
echo "alias k9s='docker run --rm -it -v $KUBECONFIG:/root/.kube/config quay.io/derailed/k9s'" >> /root/.bashrc
echo $'function fix-dashboard { kubectl patch -n kubernetes-dashboard deployment kubernetes-dashboard --patch \'{"spec": {"template": {"spec": {"containers": [{"name": "kubernetes-dashboard","imagePullPolicy": "Never"}]}}}}\'; }' >> /root/.bashrc
echo "export KUBECONFIG=/var/local/healthbot/k8s.conf" >> /home/healthbot/.bashrc
echo $'function fix-dashboard { kubectl patch -n kubernetes-dashboard deployment kubernetes-dashboard --patch \'{"spec": {"template": {"spec": {"containers": [{"name": "kubernetes-dashboard","imagePullPolicy": "Never"}]}}}}\'; }' >> /home/healthbot/.bashrc
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
sed -i "/secure_path/s/$/:\/usr\/local\/bin/" /etc/sudoers
yum -y update
yum -y install epel-release yum-utils wget 
setenforce 0
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum -y install docker-ce docker-ce-cli containerd.io wireshark jq htop vim-enhanced
yum install -y fuse-libs open-vm-tools git
systemctl start docker
systemctl enable docker
groupadd docker
usermod -aG docker healthbot
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh https://www.elrepo.org/elrepo-release-7.0-5.el7.elrepo.noarch.rpm
yum -y --enablerepo=elrepo-kernel install kernel-lt
sed -i "s/GRUB_DEFAULT=saved/GRUB_DEFAULT=0/" /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
bash -c "$(curl -sL https://get-gnmic.kmrd.dev)"
yum -y install /tmp/healthbot-*.rpm
docker pull quay.io/derailed/k9s
mv /tmp/healthbot-offline*.tgz /var/local/healthbot/
rm /tmp/healthbot*



