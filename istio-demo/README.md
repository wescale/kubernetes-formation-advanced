# Enonce

L'objectif est de refaire la démonstration vu à l'instant.

Istio est déjà installé sur votre cluster.

## Etape 1 - déploiement de l'application

```language-bash
kubectl apply -f namespace.yaml
kubectl apply -f gateway.yaml
kubectl apply -f virtualservice.yaml
kubectl apply -f application.yaml
```

Récupérez l'adresse Ip du LoadBalancer avec:

```language-bash
kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

## Etape 2 - nouvelle version

```language-bash
kubectl apply -f application-2.yaml
```

Testez avec la commande précédente.
Quel est le problème ?

```language-bash
kubectl apply -f destination-rule.yaml
```

## Etape 3 - prendre connaissance des outils

### Jaeger

```language-bash
kubectl port-forward -n istio-system $(kubectl get pod -n istio-system -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 16686:16686
```

Vous pouvez ensuite voir le dashboard ici: [http://localhost:16686](http://localhost:16686)

### Service Graph

```language-bash
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=servicegraph -o jsonpath='{.items[0].metadata.name}') 8088:8088
```

Vous pouvez ensuite voir le dashboard ici: [http://localhost:8088/force/forcegraph.html](http://localhost:8088/force/forcegraph.html)

### Grafana 

```language-bash
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000
```

Vous pouvez ensuite voir le dashboard ici: [http://localhost:3000](http://localhost:3000)
