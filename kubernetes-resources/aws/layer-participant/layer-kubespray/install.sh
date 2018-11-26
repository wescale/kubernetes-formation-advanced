#!/bin/bash

mkdir kubespray-test

cd kubespray-test

git clone https://github.com/kubernetes-incubator/kubespray

pip install -r kubespray/requirements.txt --user

cp -r kubespray/inventory/sample/ inventory-mycluster
mv hosts.ini inventory-mycluster/hosts.ini

cd kubespray
make mitogen
cd ..

ansible-playbook -i inventory-mycluster/hosts.ini kubespray/cluster.yml -b -v


