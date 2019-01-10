#!/bin/bash

# install git
sudo yum install git

# install Python dependencies installer 
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py --user
rm get-pip.py

# upgrade dependenccies for kubespray
pip install boto --user
pip install --upgrade awscli --user

# create directory for kubespray
mkdir kubespray-test
cd kubespray-test

# get Kubespray and checkout to an useful version
git clone https://github.com/kubernetes-incubator/kubespray
cd kubespray
git checkout tags/v2.5.0
cd -

# install Python dependencies
pip install -r kubespray/requirements.txt --user

# copy inventory
cp -r kubespray/inventory/sample/ inventory-mycluster
cp ../hosts.ini inventory-mycluster/hosts.ini
echo "docker_version: '18.06'" >> inventory-mycluster/group_vars/all/docker.yml
sed -i.bak "s/kube_version: v1.12.3/kube_version: v1.11.3/g" inventory-mycluster/group_vars/k8s-cluster/k8s-cluster.yml
cp docker_install.yml kubespray-test/kubespray/extra_playbooks/roles/docker/defaults/main.yml

# apply mitogen to reduced time 
# cd kubespray
# make mitogen
# cd ..

# apply playbook
ansible-playbook -i inventory-mycluster/hosts.ini kubespray/cluster.yml -b -v


