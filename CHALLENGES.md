# Challenges and Resolutions

## Overview
This document summarizes the key technical challenges encountered during
the implementation of this DevOps pipeline, and how each was resolved.

---

## 1. Jenkins PATH Issues with Docker and Trivy

### Challenge
Jenkins could not find the `docker` and `trivy` executables during pipeline
runs, throwing `docker: command not found` and `trivy: command not found`
errors. This was because Jenkins runs as a separate process and does not
inherit the system PATH from the terminal.

### Resolution
Added a `PATH+EXTRA` environment variable in Jenkins node configuration
under **Manage Jenkins → Nodes → Built-In Node → Node Properties →
Environment Variables:**
```
PATH+EXTRA = /opt/homebrew/bin:/usr/local/bin
```
This appended the Homebrew bin directory to Jenkins' PATH, making both
Docker and Trivy accessible during pipeline execution.

---

## 2. Docker Login with Special Characters in Passwords

### Challenge
The Docker Hub login step in the Jenkins pipeline failed when the password
contained special characters. Passing the password directly via shell
interpolation caused the shell to misinterpret characters like `!`, `@`,
and `$`.

### Resolution
Replaced direct credential interpolation with the `withCredentials` block
using `usernamePassword` binding. This safely masked and passed credentials
without shell interpolation issues:
```groovy
withCredentials([usernamePassword(
    credentialsId: 'dockerhub-credentials',
    usernameVariable: 'DOCKER_USER',
    passwordVariable: 'DOCKER_PASS'
)]) {
    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
}
```

---

## 3. Kubernetes Resource Quotas Blocking Pod Creation

### Challenge
After adding ResourceQuotas to the dev, staging, and prod namespaces,
all pod creation failed with:
```
must specify limits.cpu, limits.memory, requests.cpu, requests.memory
```
Kubernetes enforces that when a ResourceQuota is applied to a namespace,
all pods must explicitly declare resource requests and limits.

### Resolution
Added resource requests and limits to all 4 deployment manifests:
```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "250m"
```
This also improved cluster stability by preventing any single pod from
consuming excessive resources.

---

## 4. NodePort Conflicts Across Environments

### Challenge
When deploying to staging and production namespaces, the pipeline failed
with:
```
provided port is already allocated
```
NodePort values must be unique across the entire cluster, not just within
a namespace. Using the same NodePort numbers for dev, staging, and prod
caused conflicts since all environments share a single Minikube cluster.

### Resolution
Created environment-specific NodePort service files with unique port
numbers per environment:

| Service | Dev | Staging | Prod |
|---------|-----|---------|------|
| frontend | 30000 | 30010 | 30020 |
| product-service | 30001 | 30011 | 30021 |
| order-service | 30002 | 30012 | 30022 |
| database | 30003 | 30013 | 30023 |

The deployment pipeline was updated to apply environment-specific NodePort
files from `kubernetes/{env}/` rather than the base manifests.

---

## 5. Terraform Workspace Conflicts on Single Cluster

### Challenge
Using Terraform workspaces to manage dev, staging, and prod environments
on a single Minikube cluster caused "already exists" errors when switching
workspaces. Resources like PersistentVolumes are cluster-scoped, not
namespace-scoped, so they conflicted across workspaces.

### Resolution
Used `terraform import` to bring existing resources under the current
workspace's state management. Documented this as a known limitation of
running multiple environments on a single local cluster. In a production
cloud environment, each environment would have its own cluster, eliminating
this conflict entirely.

---

## 6. GitHub API Rate Limiting in Jenkins

### Challenge
Jenkins hit the GitHub API unauthenticated rate limit of 60 requests per
hour when scanning repositories for branches and pull requests, causing
pipeline scans to fail with a 403 error.

### Resolution
Configured a GitHub Personal Access Token in Jenkins under
**Manage Jenkins → System → GitHub Server** and associated it with the
GitHub Branch Source plugin. This raised the rate limit to 5000 requests
per hour, resolving the issue.

---

## 7. Multibranch Pipeline Not Detecting Pull Requests

### Challenge
Opening a pull request on GitHub did not trigger the PR Validation pipeline
in Jenkins. The pipeline only triggered on branch pushes, not PR events.

### Resolution
The root cause was that the Multibranch Pipeline jobs were configured with
a **Git** branch source instead of a **GitHub** branch source. The Git
source only discovers branches while the GitHub source additionally
discovers pull requests. Switching all 4 jobs to the GitHub branch source
and adding the **Discover pull requests from origin** behavior resolved
the issue.

---

## 8. Database Pods Missing Environment Variables in Staging and Prod

### Challenge
When the Jenkins pipeline deployed to staging and production using
`kubectl create deployment`, the pods were created without ConfigMaps,
Secrets, or PersistentVolumeClaims. The database crashed immediately
with:
```
Error: Database is uninitialized and superuser password is not specified
```

### Resolution
Updated `deployToK8s.groovy` to clone the infrastructure repository and
apply the full set of base manifests before updating the image tag. This
ensured ConfigMaps, Secrets, PVCs, and Services were all applied to the
target namespace before the deployment was created.

---

## 9. Ingress Host Conflict Across Namespaces

### Challenge
Deploying the frontend ingress to staging and production failed because
the host `ecommerce.local` was already defined in the dev namespace ingress,
and the nginx ingress controller rejected duplicate host definitions.

### Resolution
Updated the deployment pipeline to skip ingress files for non-dev
environments. NodePort services provide external access for staging and
production, making ingress unnecessary for local development. In a
production cloud environment, separate hostnames or subdomains would be
used per environment.