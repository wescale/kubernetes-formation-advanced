#!/bin/bash

test_tiller_present() {
    kubectl get pod -n kube-system -l app=helm,name=tiller | grep Running | wc -l | tr -d ' '
}

NB_PARTICIPANT=10
GCP_PROJECT="sandbox-training-225413"

gcloud config set project $GCP_PROJECT
gcloud iam service-accounts create admin-cluster --display-name "Admin Cluster"
gcloud projects add-iam-policy-binding $GCP_PROJECT --member serviceAccount:admin-cluster@$GCP_PROJECT.iam.gserviceaccount.com --role roles/container.admin

cd terraform
terraform apply \
    -var "nb-participants=$NB_PARTICIPANT" \
    -auto-approve
cd -

username=$(gcloud config get-value account)

istio_version="1.1.7"

if [ ! -d "istio-$istio_version" ]; then
    wget https://github.com/istio/istio/releases/download/$istio_version/istio-$istio_version-osx.tar.gz
    tar -xvf istio-$istio_version-osx.tar.gz
    rm istio-$istio_version-osx.tar.gz
fi
# export PATH="$PATH:/Users/slavayssiere/Code/kubernetes-formation-advanced/kubernetes-resources/gcp/istio-$istio_version/bin"
 
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
    helm repo add appscode https://charts.appscode.com/stable/

    helm repo update

    helm install --name prometheus-operator-cluster coreos/prometheus-operator
    helm install appscode/kubedb         --name kubedb-operator --version 0.12.0 --namespace kube-system

    cd istio-$istio_version 
    helm install install/kubernetes/helm/istio-init --name istio-init --namespace istio-system
    sleep 20
    KIALI_USERNAME=$(echo -n "admin" | base64)
    KIALI_PASSPHRASE=$(echo -n "admin" | base64)

    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: kiali
  namespace: istio-system
  labels:
    app: kiali
type: Opaque
data:
  username: $KIALI_USERNAME
  passphrase: $KIALI_PASSPHRASE
EOF

    helm install install/kubernetes/helm/istio --name istio --namespace istio-system -f ../manifests/values-istio-$istio_version.yaml
    kubectl apply -f ../expose-telemetry/
    cd -

    helm install appscode/kubedb-catalog --name kubedb-catalog  --version 0.12.0 --namespace kube-system

    kubectl create clusterrolebinding admin-cluster-admin-binding --clusterrole=cluster-admin --user=admin-cluster@$GCP_PROJECT.iam.gserviceaccount.com
    kubectl apply -f manifests/sa-admin.yaml

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

    kubectl apply -f manifests/privilege-ecalation.yaml

    ip_use=""
    ip_use=$(gcloud compute --project "$GCP_PROJECT" instances list --filter="name:training-instance-$i" --format="value(networkInterfaces[0].accessConfigs.natIP)" | head -n 1)
    

    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../kubernetes-formation $kubecfg training@${ip_use}:~/local-admin-kubeconfig
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../kubernetes-formation training@${ip_use} "git clone https://github.com/WeScale/kubernetes-formation-advanced.git"

    rm $kubecfg
done
