# Helm

## Enonce

A partir du manifest Kubernetes disponible dans "exercice-helm/base/kubernetes/webservice.yaml" il faut écrire le chart Helm.

Pour cela vous utiliserez le cluster disponible sur GCP:

- se connecter sur la VM "bastion" - le formateur vous fournira l'adresse IP - avec le compte "training" et la clef SSH disponible ici: "kubernetes-resources/kubernetes-formation"
- helm est déjà installé et configuré sur votre cluster et votre bastion

Vous pouvez créer un chart "modèle" avec la commande suivante

```language-bash
helm create mychart
```

Une fois le manifest reporté dans le chart vous pourrez tester votre chart avec la commande suivante:

```language-bash
helm install --dry-run --debug ./mychart
```

puis le déployer sur votre cluster avec la commande

```language-bash
helm install --name example ./mychart
```

pour désinstaller le chart dans le cluster

```language-bash
helm del --purge example
```

## Solution

La solution est dans le répertoire "chart"