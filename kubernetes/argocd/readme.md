## Install argocd with UI
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
## Install argocd without UI/sso etc
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/core-install.yaml

```
## Port forwaring
```
kubectl port-forward svc/argocd-server -n argocd 8080:443

```
## Expose Argocd LB
```
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

```
cl;e
## Get default password
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d


```
## Expose via http ingress with nginx with SSL from lets encrypt
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
    cert-manager.io/cluster-issuer: le-prod
    kubernetes.io/tls-acme: "true"
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
    # If you encounter a redirect loop or are getting a 307 response code
    # then you need to force the nginx ingress to connect to the backend using HTTPS.
    #
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
spec:
  ingressClassName: "nginx"
  rules:
  - host: argocd.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              name: https
  tls:
  - hosts:
    - argocd.example.com
    secretName: argocd-secret
```
## Expose via http ingress with traefik with SSL from lets encrypt
```
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: argocd-server
  namespace: argocd
spec:
  entryPoints:
    - websecure
  routes:
    - kind: Rule
      match: Host(`argocd.ragab.blog`)
      priority: 10
      services:
        - name: argocd-server
          port: 80
    - kind: Rule
      match: Host(`argocd.ragab.blog`) && Headers(`Content-Type`, `application/grpc`)
      priority: 11
      services:
        - name: argocd-server
          port: 80
          scheme: h2c
  tls:
    secretName: argocd-tls-secret
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: argocd-cert
  namespace: argocd
spec:
  secretName: argocd-tls-secret
  issuerRef:
    name: le-prod
    kind: ClusterIssuer
  dnsNames:
    - argocd.ragab.blog
```

## How to add Repository via CLI 
```
argocd repo add <REPO_URL>
# If repo is private
argocd repo add <REPO_URL> --username <USERNAME> --password <PASSWORD>
# or via ssh
argocd repo add <REPO_URL> --ssh-private-key-path <PATH_TO_SSH_PRIVATE_KEY>

```
## Create argo Project
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: {{YOUR PROJECT NAME}}
  namespace: argocd
spec:
  project: default
  source:
    repoURL: {{Your Repo URL}}
    targetRevision: HEAD
    path: productService/config/overlay/dev
  destination:
    server: {{Your cluster 'default: https://kubernetes.default.svc'}}
    namespace: {{Your namespace}}
  syncPolicy:
    automated:
      selfHeal: true
```
## [Run db migration job before every application sync ](argocd-hooks-example/README.md)

