#!/bin/bash


cd layer-participant
bastions_ip=$(terraform output list_bastion | tr "," "\n")

NUMBER=0

for ip in $bastions_ip
do
    echo "$NUMBER > [$ip]"
    export NUMBER=$NUMBER
    export NAME="cluster-$NUMBER.formation-kubernetes.wescale"

    ssh -i ../../kubernetes-formation ec2-user@${ip} "kops delete cluster $NAME --yes"

    NUMBER=$(expr $NUMBER + 1)
done

cd -

cd layer-participant
terraform destroy -auto-approve
cd -

cd layer-base
terraform destroy -auto-approve
cd -
