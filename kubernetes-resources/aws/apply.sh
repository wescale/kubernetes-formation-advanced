#!/bin/bash

cd layer-base
terraform apply \
    -auto-approve
cd -

cd layer-participant
terraform apply \
    -var "nb-participants=8" \
    -auto-approve
cd -

cd layer-participant
bastions_ip=$(terraform output list_bastion | tr "," "\n")

NUMBER=0

for ip in $bastions_ip
do
    echo "$NUMBER > [$ip]"
    export NUMBER=$NUMBER
    export NAME="cluster-$NUMBER.formation-kubernetes.wescale"
    jinja2 ./layer-kubespray/hosts.ini.tpl > ./hosts.ini
    jinja2 ./layer-kubespray/cluster-kops.yaml.tpl ../data.yaml --format=yaml > ./cluster.yaml

    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../../kubernetes-formation ./hosts.ini ec2-user@${ip}:~
    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../../kubernetes-formation layer-kubespray/install.sh ec2-user@${ip}:~
    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../../kubernetes-formation ./cluster.yaml ec2-user@${ip}:~
    rm ./hosts.ini
    rm ./cluster.yaml

    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../../kubernetes-formation ../../kubernetes-formation ec2-user@${ip}:~/.ssh/id_rsa
    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../../kubernetes-formation ../../kubernetes-formation.pub ec2-user@${ip}:~/.ssh/id_rsa.pub

    NUMBER=$(expr $NUMBER + 1)
done

cd -