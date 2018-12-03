# Prometheus Operator

L'operator Prometheus est déjà installé dans votre cluster.

## Déploiement de Prometheus

Vous pouvez déployer un prometheus dans le cluster en vous inspirant du fichier "demo-monitoring/prometheus.yaml".

Pour créer le Role vous aurez besoin de prendre un droit particulier, pour faire une élévation de privilège vous pouvez utiliser la commande suivante:

```language-bash
KUBECONFIG="/home/training/local-admin-kubeconfig" kubectl apply -f role-prometheus.yaml
```

## Déploiement applicatif

En vous inspirant de "demo-monitoring/webservice.yaml", mettez à jour votre chart Helm de ce matin pour ajouter le monitoring de l'application.
