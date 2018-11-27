#!/bin/bash

test_tiller_present() {
    kubectl get pod -n kube-system -l app=helm,name=tiller | grep Running | wc -l | tr -d ' '
}

NB_PARTICIPANT=1

gcloud config set project "sandbox-wescale"
gcloud projects add-iam-policy-binding sandbox-wescale --member serviceAccount:admin-cluster@sandbox-wescale.iam.gserviceaccount.com --role roles/container.admin

cd terraform
terraform apply \
    -var "nb-participants=$NB_PARTICIPANT" \
    -auto-approve
cd -



username=$(gcloud config get-value account)

wget https://github.com/istio/istio/releases/download/1.0.3/istio-1.0.3-osx.tar.gz
tar -xvf istio-1.0.3-osx.tar.gz
rm istio-1.0.3-osx.tar.gz
# export PATH="$PATH:/Users/slavayssiere/Code/kubernetes-formation-advanced/kubernetes-resources/gcp/istio-1.0.3/bin"
 
for i in $(seq 0 $NB_PARTICIPANT)
do
    if [[ $i -eq $NB_PARTICIPANT ]]
    then
        echo "end ! ($i/$NB_PARTICIPANT)"
        break
    else
        echo "Done for user: $i"
    fi

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

    sleep 10

    helm repo add coreos https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/
    helm install --name prometheus-operator-cluster coreos/prometheus-operator

    cd istio-1.0.3 
    helm install install/kubernetes/helm/istio --name istio --namespace istio-system -f ../values-istio.yaml
    cd -
done

