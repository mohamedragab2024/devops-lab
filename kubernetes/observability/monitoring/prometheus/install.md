```
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo add stable https://charts.helm.sh/stable
  helm repo update
  helm install prometheus prometheus-community/kube-prometheus-stack

```