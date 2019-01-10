
# cfssl gencert -initca ca-csr.json | cfssljson -bare ca

# openssl genrsa -out local-admin.key 2048
# openssl req -new -key local-admin.key -out local-admin.csr -subj "/CN=local-admin/O=system:admin"
# openssl x509 -req -in local-admin.csr -CA ../terraform/client-0.crt -CAkey ../terraform/client-0.key -CAcreateserial -out local-admin.crt -days 500

cat ../terraform/client-0.crt | base64 -D > client.crt
cat ../terraform/client-0.key | base64 -D > client.key
cat ../terraform/ca-0.crt | base64 -D > ca.crt

cfssl gencert \
  -ca=client.crt \
  -ca-key=client.key \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare local-admin


cat <<EOF | kubectl create -f -
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: csr-test
spec:
  groups:
  - system:masters
  request: $(cat local-admin.csr| base64 | tr -d '\n')
  usages:
  - digital signature
  - key encipherment
  - server auth
EOF

# kubectl describe csr csr-test
kubectl certificate approve csr-test
kubectl get csr csr-test -o jsonpath='{.status.certificate}' \
    | base64 --decode > local-admin.crt

kubecfg="test-kubecfg"
cd ../terraform
ENDPOINT=$(terraform output cluster-endpoint)
cd -

kubectl config set-cluster training-cluster-0 --server="https://${ENDPOINT}" --certificate-authority="ca.crt" --embed-certs=true --kubeconfig="$kubecfg"         
kubectl config set-credentials local-admin --client-certificate="local-admin.crt"  --client-key="local-admin-key.pem" --embed-certs=true --kubeconfig="$kubecfg"
kubectl config set-context local-admin --cluster=training-cluster-0 --namespace=default --user=local-admin --kubeconfig="$kubecfg"
kubectl config use-context local-admin  --kubeconfig="$kubecfg"

rm client.crt
rm client.key
rm ca.crt
rm local-admin*


# openssl x509 -in local-admin.pem -text -noout

KUBECONFIG="test-kubecfg" kubectl get pods
