## Install cert manager
```
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true

```

## Create cluster issuer for lets encrypt
```
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: le-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: {{Your email}}
    privateKeySecretRef:
      name: le-prod
    solvers:
      - http01:
          ingress:
            class: {{Your ingress technology such as nginx or traefik}}
```