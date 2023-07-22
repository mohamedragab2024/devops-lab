## How it works
![Alt Text](architecture-min.png)

### Add helm repo
```
helm repo add stable https://charts.helm.sh/stable

```
### Add the Prometheus community helm chart in Kubernetes

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

```
```
helm search repo prometheus-community
helm install [RELEASE_NAME] prometheus-community/kube-prometheus-stack

```