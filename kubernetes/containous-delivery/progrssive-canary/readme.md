# Progessive Canary deployment using template analysis
## Requirments tools
- Kubernetes cluster
```
# using Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube start --cpus 8 --memory 8192
# Install Loadbalancer using metallb
minikube addons enable metallb
minikube addons configure metallb 
-- Enter Load Balancer Start IP: $(minikube ip) 
-- Enter Load Balancer End IP: $(minikube ip)
# Install nginx ingress
minikube addons enable ingress
kubectl patch svc ingress-nginx-controller -n ingress-nginx -p '{"spec": {"type": "LoadBalancer"}}'

# Now you can use output of minikube ip from your browser you will redirect to nginx default page

```
- Install service-mesh solution for this demo we use (Linkerd)
```
# Install linkrd ctl 
curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/install | sh
export PATH=$HOME/.linkerd2/bin:$PATH
# check if your k8s cluster compatible with linkerd or not 
linkerd check --pre

# Install linkerd  CRDS

linkerd install --crds | kubectl apply -f -

#Install linkerd core compontents

linkerd install | kubectl apply -f -

# check Linkerd installation

linkerd check

# Install an on-cluster metric stack and dashboard such as prometheus

linkerd viz install | kubectl apply -f -

# check Linkerd

linkerd check

```
- Install ArgoRollout

```
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

```
- Install ArgoCD

```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# If you want to create L7 ingress to access argocd 

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server
  namespace: argocd
  annotations:
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
spec:
  ingressClassName: "nginx"
  rules:
  - host: argocd.ragab.biz
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              name: https

# We can also use LoadBalancer IP with argocd PORT
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

```
- Install ArgoCD CLI

```
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

```

## Deploy ArgoCD project 

```
# if you have L7 ingress you can use it or port-forward argocd server service
kubectl port-forward svc/argocd-server 8080:8080 -n argocd

export CONFIG_REPO=https://github.com/ragoob/devops-lab.git

export ARGOCD_SERVER=argocd.ragab.biz

# To get admin password 
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode

argocd login $ARGOCD_SERVER
argocd repo add $CONFIG_REPO

# Create application namespace

kubectl create namespace devops-lab-demos
# create argocd project


argocd proj create devops-lab-demos -d https://kubernetes.default.svc,devops-lab-demos -s $CONFIG_REPO


```