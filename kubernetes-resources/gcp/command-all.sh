#!/bin/bash

list_ip=$(gcloud compute --project "sandbox-wescale" instances list --filter="name:training-instance*" --format="value(networkInterfaces[0].accessConfigs.natIP)")

echo $list_ip

index=0

for ip in $list_ip
do
    echo "ip = ${ip}"

    username=$(gcloud config get-value account)
    kubectl create clusterrolebinding user-admin-binding --clusterrole=cluster-admin --user=$username
    
    echo "Done for ${ip}"

done

echo "Done"