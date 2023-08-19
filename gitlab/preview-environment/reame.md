### Creating Environments for Every Pull Request using GitLab, Kustomize, and Kubernetes
In this guide, we'll walk through the process of setting up automated environment creation for each pull request using GitLab, Kustomize, and Kubernetes.  If you are not familiar with Kustomize, you can check out our [GitOps series on YouTube](https://www.youtube.com/playlist?list=PLTRDUPO2OmInz2Fo41zwnoR1IArx70Hig)

## Requirement
- An existing Kubernetes cluster.
- Kubeconfig file for cluster access.

## Create Job triggered only merge_request
- prepare stage environment
  using alpine image as a runner and install curl,jq,kubectl , kustomize
- create variable in gitlab project CI setting  with type file , name KUBECONFIG and the content is your kubeconfig file content to access K8s cluster  
```
merge_request_deploy_job:
    image: alpine:latest
    tags:
    - k8s
    stage: deploy
    before_script:
     - apk add --update --no-cache curl
     - apk --no-cache add jq
     - apk add bash
     - curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
     - chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl
     - mkdir -p $HOME/.kube
     - echo "$KUBECONFIG" > $HOME/.kube/config
     -  |
         curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash && \
         mv kustomize /usr/local/bin/kustomize
```
####  script do the following
- First, edit your DNS in the ingress to create an ingress for every pull request, using the format ${CI_MERGE_REQUEST_IID}.example.com, in the Kustomize files
```
    - sed -i "s/items-service.${YOUR_DOMAIN}/pr-${CI_MERGE_REQUEST_IID}.${YOUR_DOMAIN}/" config/base/route.yaml

```
- In the overlay preview environment, create a namespace for the pull request. We utilize a dry run and apply strategy to prevent imperative actions and potential errors if the namespace already exists
```
kubectl create ns items-service-pr-$CI_MERGE_REQUEST_IID --dry-run=client -o yaml | kubectl apply -f -
``` 
- Create a Docker registry secret if it is needed to be used as a pull secret
```
 kubectl create secret docker-registry docker-secret \
       --docker-server=$CI_REGISTRY \
       --docker-username=$CI_REGISTRY_USER \
       --docker-password=$CI_REGISTRY_PASSWORD --dry-run=client -o yaml | kubectl apply -f - \
       -n items-service-pr-$CI_MERGE_REQUEST_IID
```
- Utilize the kustomize edit command to dynamically set the image, incorporating the pull request prefix.
```
kustomize edit set image ${YOUR_DOCKER_USER_NAME}/items-service=$CI_REGISTRY_USER/$CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG-$CI_COMMIT_SHORT_SHA && \
       kustomize build . | kubectl apply -f - -n items-service-pr-$CI_MERGE_REQUEST_IID
```
- Restrict the job to run only on merge requests.
```
only:
    - merge_requests
```
### Now how we can cleanup the environment
  We need to clean up and remove the namespace when the pull request is merged
 #### Note: There is no direct way to accomplish this through pipeline jobs triggered by push changes. However, we can create a cleanup job in the base branch against which the pull request is created
#### requirements
- gitlab access token to read apis only
- create a cleanup job and stage
- use alpine image or what ever you want
```
cleanup:
  stage: cleanup
  image: alpine:latest
```
- prepare the runner environment we need curl,jq,kubectl
```
 before_script:
     - apk add --update --no-cache curl
     - apk --no-cache add jq
     - apk add bash
     - curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
     - chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl
     - mkdir -p $HOME/.kube
     - echo "$KUBECONFIG" > $HOME/.kube/config
```
- Subsequently, we need to call the GitLab API to retrieve a list of merged pull requests. By using jq, we extract only the 'iid' and prefix it with the namespace prefix, 'items-service-pr-'. This prepared list is then utilized to run the 'kubectl delete namespace' command against the respective namespaces
```
script:
    - kubectl delete ns $(curl -s --header "PRIVATE-TOKEN:$PRIVATE_TOKEN" "$GITLAB_API_URL/projects/$PROJECT_ID/merge_requests?state=merged" | jq '.[].iid | "items-service-pr-" + tostring' | tr -d '"') --ignore-not-found=true 
```
- Restrict the job to run only on base branch
```
 only:
   - main
```