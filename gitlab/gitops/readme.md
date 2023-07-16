# GitLab CI
## Requirements
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