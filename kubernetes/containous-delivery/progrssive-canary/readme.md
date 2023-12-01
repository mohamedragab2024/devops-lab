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
- Install service-mesh solution for this demo we use (Linkerd) for easy collect metric about services
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

# install argo-rollouts kubectl plugin
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
chmod +x ./kubectl-argo-rollouts-linux-amd64

sudo mv ./kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts
# Allow argo-rollout controller to scrape prometheus in viz 
linkerd viz allow-scrapes --namespace argo-rollouts | kubectl apply -f -

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

# to access the local ingress edit /etc/hosts and add the dns record with the ip of minikube 

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

# Inject devops-lab-demos namespace with linkerd proxy sidecar
kubectl annotate namespace devops-lab-demos linkerd.io/inject=enabled

# create argocd project


argocd proj create devops-lab-demos -d https://kubernetes.default.svc,devops-lab-demos -s $CONFIG_REPO
# Create argocd app to sync k8s objects 
kubectl apply -f canary-demo-argo-app.yaml -n argocd
# Note : You can create app using argocd UI
```
# Explain K8s manifest
 - Using Kustomize 
 we have the following objects
 - argorollout which is replacement of traditional k8s deployment object but allow extra deployment
   stratgies such as blue-green, canary , progressive
 ```
 apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: canary-demo-web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: canary-demo-web
  template:
    metadata:
      labels:
        app: canary-demo-web
    spec:
      containers:
      - name: canary-demo-web
        image: regoo707/canary-demo-web:1.0.0
        ports:
        - containerPort: 3000
  minReadySeconds: 30
  revisionHistoryLimit: 3
  strategy:
    canary:
      canaryService: canary-demo-web-canary  # canary backend service use to split traffic
      stableService: canary-demo-web-stable  # stable backend service
      trafficRouting:
        nginx:
          stableIngress: canary-demo-web
      analysis:
        templates:
        - templateName: success-rate  # analysis template object name
        startingStep: 2
        args:
        - name: service-name
          value: canary-demo-web
      steps:
      - setWeight: 20
      - pause: {duration: 2m}
      - setWeight: 40
      - pause: {duration: 3m}
      - setWeight: 60
      - pause: {duration: 4m}
      - setWeight: 80
      - pause: {duration: 5m}
 ``` 
 - Two service objects one for stable ingress and the other one for canary ingress 
   that argorollout controller will create it on the fly to control the traffic
  ```
  kind: Service
apiVersion: v1
metadata:
  name:  canary-demo-web-stable
spec:
  selector:
    app:  canary-demo-web
  type:  ClusterIP
  ports:
  - name:  http
    port:  80
    targetPort:  3000
  ---
  kind: Service
apiVersion: v1
metadata:
  name:  canary-demo-web-canary
spec:
  selector:
    app:  canary-demo-web
  type:  ClusterIP
  ports:
  - name:  http
    port:  80
    targetPort:  3000
  ```
- Ingress for stable service (The canary one will create and mange by argorollout controller)
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: canary-demo-web
  namespace: devops-lab-demos
  annotations:
    nginx.ingress.kubernetes.io/service-upstream: "true"
spec:
  ingressClassName: "nginx"
  rules:
  - host: canary-demo-web.ragab.biz
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: canary-demo-web-stable
            port:
              name: http
```
- Analysis template used as source of health of deployment we use prometheus http sucess response / total response 
```
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: success-rate
spec:
  args:
  - name: service-name
  metrics:
  - name: success-rate
    interval: 1m
    successCondition: result[0] >= 0.95
    failureLimit: 3
    provider:
      prometheus:
        address: http://prometheus.linkerd-viz.svc.cluster.local:9090 # prometheus instance from linkerd-viz
        timeout: 40
        query: |
          sum(irate(response_total{direction = "inbound", app="{{args.service-name}}",status_code !~"5.*"}[1m]))
          /
          sum(irate(response_total{direction = "inbound",app="{{args.service-name}}"}[1m]))

```
- Overlays for kustomize environments 

# Explain 
-  When deploying a new version (e.g., 1.0.1), ArgoRollout dynamically generates a canary ingress with two distinct annotations for nginx:

```
nginx.ingress.kubernetes.io/canary: "true"
nginx.ingress.kubernetes.io/canary-weight: "0"
# https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#canary
```

-  This facilitates traffic division between the stable version 1.0.0 and the new version 1.0.1, leveraging a Prometheus query result:

```
sum(irate(response_total{direction = "inbound", app="{{args.service-name}}", status_code !~ "5.*"}[1m]))
/
sum(irate(response_total{direction = "inbound", app="{{args.service-name}}"}[1m]))

```


-  Under successful conditions, the nginx.ingress.kubernetes.io/canary-weight will increment based on the step template provided in the analysis. This involves incremental increases at 20%, 40%, and 60% until version 1.0.0 is entirely replaced by 1.0.1. Simultaneously, the routing of traffic to 1.0.0 will cease, and all replica pods running 1.0.0 will be stopped.

-  However, if the query yields insufficient results, a rollback to version 1.0.0 will commence, and the progression of the canary deployment will be halted."


