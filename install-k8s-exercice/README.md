# KubeSpray

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

## Avec KubeSpray

Une fois sur le bastion, vous trouverez un ficher "install.sh" avec la marche à suivre.
