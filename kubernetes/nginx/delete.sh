cd kubernetes-ingress/deployments
kubectl delete -f rbac/rbac.yaml
kubectl delete -f rbac/ap-rbac.yaml
kubectl delete -f rbac/apdos-rbac.yaml
kubectl delete -f ../examples/shared-examples/default-server-secret/default-server-secret.yaml
kubectl delete -f common/nginx-config.yaml
kubectl delete -f common/ingress-class.yaml
kubectl delete -f common/crds/k8s.nginx.org_virtualservers.yaml
kubectl delete -f common/crds/k8s.nginx.org_virtualserverroutes.yaml
kubectl delete -f common/crds/k8s.nginx.org_transportservers.yaml
kubectl delete -f common/crds/k8s.nginx.org_policies.yaml
kubectl delete -f common/crds/k8s.nginx.org_globalconfigurations.yaml
kubectl delete -f common/crds/appprotect.f5.com_aplogconfs.yaml
kubectl delete -f common/crds/appprotect.f5.com_appolicies.yaml
kubectl delete -f common/crds/appprotect.f5.com_apusersigs.yaml
# DDOS protection
kubectl delete -f common/crds/appprotectdos.f5.com_apdoslogconfs.yaml
kubectl delete -f common/crds/appprotectdos.f5.com_apdospolicy.yaml
kubectl delete -f common/crds/appprotectdos.f5.com_dosprotectedresources.yaml
kubectl delete -f deployment/appprotect-dos-arb.yaml
kubectl delete -f service/appprotect-dos-arb-svc.yaml
kubectl delete -f deployment/nginx-ingress.yaml
kubectl delete -f daemon-set/nginx-ingress.yaml
kubectl delete -f service/loadbalancer.yaml
kubectl delete -f common/ns-and-sa.yaml
