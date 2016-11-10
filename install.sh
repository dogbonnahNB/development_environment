#!/bin/bash
set -eux

swapoff /dev/vg-workstation/swap
lvremove -y /dev/vg-workstation/swap
lvcreate -L 4G -n swap vg-workstation
dd if=/dev/zero of=/dev/vg-workstation/swap bs=1M count=4096
mkswap /dev/vg-workstation/swap
swapon /dev/vg-workstation/swap
lvextend --size +15G /dev/vg-workstation/tmp
resize2fs /dev/vg-workstation/tmp

sed -i '8i SHELL=/bin/bash' /etc/default/useradd
sed -i '9d' /etc/default/useradd
sed -i '6i DSHELL=/bin/bash' /etc/adduser.conf
sed -i '7d' /etc/adduser.conf

sed -i '6i XKBLAYOUT="gb"' /etc/default/keyboard
sed -i '7d' /etc/default/keyboard

apt-get -y install openjdk-8-jdk
apt-get -y install openvpn

curl -y -Lo kubectl http://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/
curl -y -Lo minikube https://storage.googleapis.com/minikube/releases/v0.12.0/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/

OS=$(cat /etc/os-release|sed -e 's/"//'|grep ID_LIKE|awk -F '=' '{print $2}'|awk '{print $1}')

if [ ${OS} == "debian" ]
then
  apt-get -y install python-pip git libssl-dev libffi-dev
  pip install 'docker-py==1.9.0'
fi

if [ ${OS} == "rhel" ]
then
  yum install -y epel-release 
  yum install -y git python-pip gcc-c++ openssl-devel python-devel
  pip install 'docker-py==1.9.0'
fi

pip install --upgrade pip setuptools ansible

mkdir -p /opt/GIT

cd /opt/GIT

if [ ! -d development_environment]
then
  git clone https://github.com/dogbonnahNB/development_environment.git development_environment
else
  rm -rf development_environment
  git clone https://github.com/dogbonnahNB/development_environment.git development_environment
fi

cd development_environment

git submodule init
git submodule update

ansible-galaxy install -r requirements.yml

ansible-playbook -i hostfile -v site.yml

exit
