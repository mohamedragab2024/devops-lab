### Jaeger: open source, end-to-end distributed tracing
     Monitor and troubleshoot transactions in complex distributed systems 

### Install on K8s using helm
```
helm repo add jaeger https://jaegertracing.github.io/helm-charts
helm repo update
# Default storage is cassandra you can override it by --set storage.type={storage type}
helm install jaeger jaeger/jaeger --namespace observability
kubectl port-forward -n jaeger service/jaeger-query 16686:16686
# Load balancer expose
helm upgrade --install jaeger jaeger/jaeger --namespace observability --set query.service.type=LoadBalancer --set storage.type=memory

```