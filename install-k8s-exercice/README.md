# On AWS / OnPremise

L'objectif ici est d'installer Kubernetes en utilisant Kubespray et Kops

Vous pouvez vous connecter sur le bastion AWS en utilisant la clef "kubernetes-resources/kubernetes-formation" et le user "ec2-user".

## Avec Kops

```language-bash
kops create -f cluster.yaml
```

Pour créer la clef de connexion au cluster:

```language-bash
kops create secret --name cluster-(mon numero).formation-kubernetes.wescale sshpublickey admin -i ~/.ssh/id_rsa.pub
```

Comme indiqué, lancez la commande:

```language-bash
kops update cluster cluster-(mon numero).formation-kubernetes.wescale --yes
```

Pour attendre la validation du cluster:

```language-bash
until kops validate cluster; do echo "wait"; sleep 5; done
```

Pour créer le kubeconfig:

```language-bash
kops export kubecfg cluster-(mon numero).formation-kubernetes.wescale
```


## Avec KubeSpray

Une fois sur le bastion, vous trouverez un ficher "install.sh" avec la marche à suivre.

## Installer les outils

### Ajouter Helm

#### Ajouter les droits RBAC pour Tiller

Avec le YAML suivant:

```language-yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
```

#### Initialiser Helm

```language-bash
helm init --service-account tiller
```

### Installer le prometheus-operator

Aller sur [https://hub.kubeapps.com/](https://hub.kubeapps.com/) pour chercher votre package.

Installer le prometheus-operator avec:

```language-bash
helm install stable/prometheus-operator --version 0.1.29
```
