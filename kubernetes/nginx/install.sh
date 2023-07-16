git clone https://github.com/nginxinc/kubernetes-ingress.git --branch v3.2.0
cd kubernetes-ingress/deployments
kubectl apply -f common/ns-and-sa.yaml
kubectl apply -f rbac/rbac.yaml
kubectl apply -f rbac/ap-rbac.yaml
kubectl apply -f rbac/apdos-rbac.yaml
kubectl apply -f ../examples/shared-examples/default-server-secret/default-server-secret.yaml
kubectl apply -f common/nginx-config.yaml
kubectl apply -f common/ingress-class.yaml
kubectl apply -f common/crds/k8s.nginx.org_virtualservers.yaml
kubectl apply -f common/crds/k8s.nginx.org_virtualserverroutes.yaml
kubectl apply -f common/crds/k8s.nginx.org_transportservers.yaml
kubectl apply -f common/crds/k8s.nginx.org_policies.yaml
kubectl apply -f common/crds/k8s.nginx.org_globalconfigurations.yaml
kubectl apply -f common/crds/appprotect.f5.com_aplogconfs.yaml
kubectl apply -f common/crds/appprotect.f5.com_appolicies.yaml
kubectl apply -f common/crds/appprotect.f5.com_apusersigs.yaml
# DDOS protection
kubectl apply -f common/crds/appprotectdos.f5.com_apdoslogconfs.yaml
kubectl apply -f common/crds/appprotectdos.f5.com_apdospolicy.yaml
kubectl apply -f common/crds/appprotectdos.f5.com_dosprotectedresources.yaml
kubectl apply -f deployment/appprotect-dos-arb.yaml
kubectl apply -f service/appprotect-dos-arb-svc.yaml
kubectl apply -f deployment/nginx-ingress.yaml
kubectl apply -f daemon-set/nginx-ingress.yaml
kubectl apply -f service/loadbalancer.yaml
