## Use ARGOCD hook to run .net ef core db migration job before sync new application version 
## Notes for real and on production case do not store stuff like Connection string in git instead use sealed secrets or vault
   In your config in base of kustomize add the following job 
   ```
apiVersion: batch/v1
kind: Job
metadata:
  generateName: schema-migrate-
  name: schema-migration
  annotations:
    argocd.argoproj.io/hook: PreSync
spec:
  ttlSecondsAfterFinished: 100
  template:
    spec:
      containers:
      - name: ef-migration
        image: mcr.microsoft.com/dotnet/sdk:6.0
        command: ["/bin/bash","-c",  "apt install git -y && git clone $GIT_REPO && cd $SERVICE_PATH && dotnet tool install --global dotnet-ef && export PATH=\"$PATH:/root/.dotnet/tools\" && dotnet ef database update"]
        env:
        - name: GIT_REPO
          value: {{Your ef core migration file repository aka your code repository}}
        - name: ConnectionStrings__DefaultConnection
          value: Host={{Your connection string recommended to use secerts}}
        - name: SERVICE_PATH
          value: gitops-dotnet-web-app/productService
      restartPolicy: Never

   ```
```
kubectl apply -f argocd/product-service-app.yaml . -n argocd

```
