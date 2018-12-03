#!/bin/bash

test_tiller_present() {
    kubectl get pod -n kube-system -l app=helm,name=tiller | grep Running | wc -l | tr -d ' '
}

NB_PARTICIPANT=2

gcloud config set project "sandbox-wescale"
gcloud iam service-accounts create admin-cluster --display-name "Admin Cluster"
gcloud projects add-iam-policy-binding sandbox-wescale --member serviceAccount:admin-cluster@sandbox-wescale.iam.gserviceaccount.com --role roles/container.admin

cd terraform
terraform apply \
    -var "nb-participants=$NB_PARTICIPANT" \
    -auto-approve
cd -

username=$(gcloud config get-value account)

if [ ! -d "istio-1.0.3" ]; then
    wget https://github.com/istio/istio/releases/download/1.0.3/istio-1.0.3-osx.tar.gz
    tar -xvf istio-1.0.3-osx.tar.gz
    rm istio-1.0.3-osx.tar.gz
fi
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

    kubectl create clusterrolebinding admin-cluster-admin-binding --clusterrole=cluster-admin --user=admin-cluster@sandbox-wescale.iam.gserviceaccount.com
    kubectl apply -f sa-admin.yaml

    kubecfg="kubeconfig-$i"

    secret_sa=$(kubectl get sa local-admin -o json | jq -r .secrets[]."name")

    token=$(kubectl get secret $secret_sa -o jsonpath={.data.token} | base64 -D)

    kubectl get secret "${secret_sa}" -o json | jq  -r '.data["ca.crt"]' | base64 -D > "ca.crt"

    context=$(kubectl config current-context)
    echo -e "Setting current context to: $context"

    CLUSTER_NAME=$(kubectl config get-contexts "$context" | awk '{print $3}' | tail -n 1)
    echo "Cluster name: ${CLUSTER_NAME}"

    ENDPOINT=$(kubectl config view -o jsonpath="{.clusters[?(@.name == \"${CLUSTER_NAME}\")].cluster.server}")
    echo "Endpoint: ${ENDPOINT}"

    echo -n "Setting a cluster entry in kubeconfig..."
    kubectl config set-cluster "${CLUSTER_NAME}" \
        --kubeconfig="$kubecfg" \
        --server="${ENDPOINT}" \
        --certificate-authority="ca.crt" \
        --embed-certs=true

    echo -n "Setting token credentials entry in kubeconfig..."
    kubectl config set-credentials \
        "local-admin" \
        --kubeconfig="$kubecfg" \
        --token="$token"

    echo -n "Setting a context entry in kubeconfig..."
    kubectl config set-context \
        "local-admin" \
        --kubeconfig="$kubecfg" \
        --cluster="${CLUSTER_NAME}" \
        --user="local-admin"

    echo -n "Setting the current-context in the kubeconfig file..."
    kubectl config use-context "local-admin" \
        --kubeconfig="${kubecfg}"

    kubectl apply -f privilege-ecalation.yaml

    ip_use=""
    ip_use=$(gcloud compute --project "sandbox-wescale" instances list --filter="name:training-instance-$i" --format="value(networkInterfaces[0].accessConfigs.natIP)")
    

    scp -i ../kubernetes-formation $kubecfg training@${ip_use}:~/local-admin-kubeconfig


done

# list_ip=$(gcloud compute --project "sandbox-wescale" instances list --filter="name:training-instance*" --format="value(networkInterfaces[0].accessConfigs.natIP)")

# NUMBER=0
# for ip in $list_ip
# do
#     echo "ip = ${ip}"
#     echo "ip_use = ${ip_use}"
#     kubecfg="kubeconfig-$NUMBER"


#     echo "Done for ${ip}"
#     NUMBER=$(expr $NUMBER + 1)
# done
