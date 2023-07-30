# GitLab Complete CI including static code analysis and semantic versioning
## Install GitLab Runner
- GitLab Runner machine to handle the CI stages with docker installed
```
Linux install 
# Download the binary for your system
sudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64

# Give it permission to execute
sudo chmod +x /usr/local/bin/gitlab-runner

# Create a GitLab Runner user
sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
#Register
sudo gitlab-runner register -n \
  --url https://gitlab.com/ \
  --registration-token {YOUR_TOKEN} \
  --executor docker \
  --description "My Docker Runner" \
  --docker-image "docker:20.10.16" \
  --docker-privileged \
  --docker-volumes "/certs/client" \
  --tag-list "devops"

```
## Create access token for the following
### - Sonarqube 
### - Semantic release
### - GitLab K8s config repository (pull - push - create branch)
### - GitLab API to create MR(aka PR)

### Semantic release create .releaserc.json on your app repository (semantic release configuration)
```
{
    "plugins": [
        "@semantic-release/commit-analyzer",
        "@semantic-release/release-notes-generator",
        [
            "@semantic-release/changelog",
            {
                "changelogFile": "CHANGELOG.md"
            }
        ],
        [
            "@semantic-release/git",
            {
                "assets": [
                    "CHANGELOG.md"
                ]
            }
        ]
    ],
    "branches": [
        "main",
        "+([0-9])?(.{+([0-9]),x}).x",
        {
            "name": "beta",
            "prerelease": true
        }
    ]
}
```
#### Add commit-msg in your .git/hooks
```
#!/usr/bin/env bash

if [ -z "$1" ]; then
	echo "Missing argument (commit message). Did you try to run this manually?"
	exit 1
fi

commit_message_file=$1
commit_message=$(cat $commit_message_file)
semantic_release_pattern='^(build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test)(\([^)]+\))?!?: .+'

# ignore merge requests
if echo "$commitTitle" | grep -qE "Merge branch"; then
	echo "Commit hook: ignoring branch merge"
	exit 0
fi

# check semantic versioning scheme
if [[ ! $commit_message =~ $semantic_release_pattern ]]; then
	echo "Your commit title did not follow semantic versioning: $commitTitle"
	echo "Please see https://github.com/angular/angular.js/blob/master/DEVELOPERS.md#commit-message-format"
	exit 1
fi

```
## SonarQube
- You need Sonar instance either cloud based or custom install (developer edition)
In GitLab > Setting > CI/CD > Add the following variables
- SONAR_HOST_URL (your sonar instance URL)
- SONAR_TOKEN (your sonar project token)
#### Add sonar-project.properties for your code repository based on your programming languge example for our golang project 

```
sonar.projectKey={SONAR_PROJECT_KEY}
sonar.organization{SONAR_ORG}
sonar.qualitygate.wait=true
sonar.go.coverage.reportPaths=coverage-report.out
sonar.exclusions=coverage-report.html
sonar.test.inclusions=*_test.go
```
### CI/CD 
#### Create .gitlab-ci.yml that include gitops process and steps
### Make merge request (PR) setting to pipeline must succeed

### Adding badges 
Your gitlab project > setting > General >Badges
### Pipeline badge 
```
https://gitlab.com/{USER_NAME}/{REPO_NAME}/badges/main/pipeline.svg

```
### Code converage 
```
https://gitlab.com/{USER_NAME}/{REPO_NAME}/badges/main/coverage.svg
```
### Sonar Quality gate status
```
https://sonarcloud.io/api/project_badges/measure?project={YOUR_SONAR_PROJECT_NAME}&metric=alert_status

```
## GitLab CLI create the following file in your app repository
```
image: docker:20.10.16
variables:
   DOCKER_TLS_CERTDIR: "/certs"
services:
  - docker:20.10.16-dind
stages:
  - build
  - test
  - sonarqube
  - docker-build
  - release
  - deploy

build_job:
  stage: build
  image: golang:alpine
  tags:
  - devops
  script:
    - go get .
    - go build
  only:
    - tags
    - main
    - develop
    - merge_requests
test_job:
  stage: test
  image: golang:alpine
  tags:
  - devops
  script:
    - go get .
    - go test ./... -coverprofile=coverage-report.out
    - go tool cover -html=coverage-report.out -o coverage-report.html
    - go tool cover -func=coverage-report.out
  artifacts:
    paths:
      - coverage-report.html
      - coverage-report.out
    expire_in: 1 hour
  coverage: "/\\(statements\\)\\s+\\d+.?\\d+%/"
  only:
    - tags
    - main
    - develop
    - merge_requests
sonarqube_job:
  stage: sonarqube
  tags:
  - devops
  image: 
    name: sonarsource/sonar-scanner-cli:latest
    entrypoint: [""]
  variables:
    SONAR_USER_HOME: "${CI_PROJECT_DIR}/.sonar"
    GIT_DEPTH: "0" 
  cache:
    key: "${CI_JOB_NAME}"
    paths:
      - .sonar/cache
  script: 
    - sonar-scanner
  allow_failure: true
  only:
    - merge_requests
    - main
docker_job:
  stage: docker-build
  tags:
  - devops
  script:
  - |
      if [[ -z "${CI_COMMIT_TAG}" ]]; then
        export VERSION_TAG="${CI_COMMIT_SHORT_SHA}"
      else
        export VERSION_TAG="${CI_COMMIT_TAG//v}"
      fi
  - docker build -t $DOKCER_IMAGE_NAME:$VERSION_TAG .
  - echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USERNAME --password-stdin
  - docker push $DOKCER_IMAGE_NAME:$VERSION_TAG

  only:
    - tags
    - develop
release_job:
  stage: release
  image: node
  tags:
  - devops
  script:
  - npm -g install @semantic-release/git semantic-release @semantic-release/changelog && semantic-release
  only:
   - main
   - /^(([0–9]+)\.)?([0–9]+)\.x/

update_k8s_config_job:
  stage: deploy
  image: ubuntu
  tags:
  - devops
  before_script:
  - apt update
  - apt install git -y && apt install curl -y
  script:
  - |
      if [[ -z "${CI_COMMIT_TAG}" ]]; then
        export VERSION_TAG="${CI_COMMIT_SHORT_SHA}"
      else
        export VERSION_TAG="${CI_COMMIT_TAG//v}"
      fi
  - echo ${VERSION_TAG}
  - git clone https://gitlab-ci-token:${GITLAB_TOKEN}@$CONFIG_REPOSITORY_URL
  - cd gitops-config
  - git config --global user.email $GIT_CONFIG_EMAIL
  - git config --global user.name $GIT_CONFIG_NAME
  - git checkout -b release
  - cd overlay/prod && sed -i "s/^ *newTag:.*/  newTag:${VERSION_TAG}/" kustomization.yaml
  - git add . && git commit -am "Add new build version ${VERSION_TAG}"
  - git push  --set-upstream origin release
  - |
      curl --request POST --header "PRIVATE-TOKEN: $MR_CREATOR_TOKEN" \
           --form "source_branch=release" \
           --form "target_branch=main" \
           --form "title=[CI update] New release ${VERSION_TAG}" \
           --form "description=New release to be reviewed and promoted ${VERSION_TAG}" \
           "https://gitlab.com/api/v4/projects/$CONFIG_PROJECT_ID/merge_requests"
  only:
   - tags

```