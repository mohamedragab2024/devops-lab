```
helm install traefik traefik/traefik --namespace=traefik --version=23.1.0
```

kubectl run curl-pod --restart=Never --image=curlimages/curl --rm -it -- sh -c "curl https://argocd.ragab.blog"
