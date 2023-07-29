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

## Install prometheus with grafana custom values and with postgres exporter
```
 
  helm install prometheus-stack prometheus-community/kube-prometheus-stack -f values.yaml
  # Install with postgres exporter
  helm upgrade --install prometheus-stack prometheus-community/kube-prometheus-stack -f values.yaml

```