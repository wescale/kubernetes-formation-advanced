# https://blog.zwindler.fr/2017/12/05/installer-kubernetes-kubespray-ansible/
[all]
master-{{ environ('NUMBER') }} ansible_host="master-{{ environ('NUMBER') }}.formation-kubernetes.wescale" ansible_user=ubuntu
worker-a-{{ environ('NUMBER') }} ansible_host="worker-a-{{ environ('NUMBER') }}.formation-kubernetes.wescale" ansible_user=ubuntu
worker-b-{{ environ('NUMBER') }} ansible_host="worker-b-{{ environ('NUMBER') }}.formation-kubernetes.wescale" ansible_user=ubuntu
worker-c-{{ environ('NUMBER') }} ansible_host="worker-c-{{ environ('NUMBER') }}.formation-kubernetes.wescale" ansible_user=ubuntu

[kube-master]
master-{{ environ('NUMBER') }}

[etcd]
master-{{ environ('NUMBER') }}

[kube-node]
worker-a-{{ environ('NUMBER') }}
worker-b-{{ environ('NUMBER') }}
worker-c-{{ environ('NUMBER') }}

[k8s-cluster:children]
kube-master
kube-node

[calico-rr]
