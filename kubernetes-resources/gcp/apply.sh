#!/bin/bash

test_tiller_present() {
    kubectl get pod -n kube-system -l app=helm,name=tiller | grep Running | wc -l | tr -d ' '
}

NB_PARTICIPANT=1

gcloud config set project "sandbox-wescale"

cd terraform
terraform apply \
    -var "nb-participants=$NB_PARTICIPANT"
cd -

username=$(gcloud config get-value account)
 
for i in $(seq 0 $NB_PARTICIPANT)
do
    gcloud container clusters get-credentials "training-cluster-$i" --zone europe-west1-b
    kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$username
    kubectl apply -f ./traefik-ic/traefik-rbac.yaml
    kubectl apply -f ./traefik-ic/traefik-ds.yaml

    kubectl -n kube-system create sa tiller
    kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
    helm init --service-account tiller

    toto=$(test_tiller_present)
    while [ $toto -lt 1 ]; do
      echo "Wait for Tiller: $toto"
      toto=$(test_tiller_present)
      sleep 1
    done

    helm repo add coreos https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/
    helm install --name prometheus-operator-cluster coreos/prometheus-operator
done

