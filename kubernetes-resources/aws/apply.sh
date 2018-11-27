#!/bin/bash

# cd layer-base
# terraform apply
# cd -

# cd layer-participant
# terraform apply \
#     -var "nb-participants=2"
# cd -

cd layer-participant
bastions_ip=$(terraform output list_bastion | tr "," "\n")

for ip in $bastions_ip
do
    echo "> [$ip]"
    scp -i ../../kubernetes-formation layer-kubespray/hosts.ini ec2-user@${ip}:~
    scp -i ../../kubernetes-formation layer-kubespray/install.sh ec2-user@${ip}:~

    ssh -i ../../kubernetes-formation ec2-user@${ip} "mkdir .ssh"
    scp -i ../../kubernetes-formation ../../kubernetes-formation ec2-user@${ip}:~/.ssh/id_rsa
    scp -i ../../kubernetes-formation ../../kubernetes-formation.pub ec2-user@${ip}:~/.ssh/id_rsa.pub
done
cd -