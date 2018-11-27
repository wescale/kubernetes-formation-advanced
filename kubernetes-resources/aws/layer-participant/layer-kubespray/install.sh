#!/bin/bash

curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py --user
pip install boto --user
pip install --upgrade awscli --user

mkdir kubespray-test

cd kubespray-test

git clone https://github.com/kubernetes-incubator/kubespray

cd kubespray
git checkout tags/v2.7.0
cd -

pip install -r kubespray/requirements.txt --user

cp -r kubespray/inventory/sample/ inventory-mycluster
cp ../hosts.ini inventory-mycluster/hosts.ini

cd kubespray
make mitogen
cd ..

ansible-playbook -i inventory-mycluster/hosts.ini kubespray/cluster.yml -b -v


