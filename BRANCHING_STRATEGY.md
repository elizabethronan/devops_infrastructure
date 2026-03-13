# Branching Strategy

## Overview
This project follows Git Flow, a branching model designed for managing
releases in a structured and predictable way. Each branch type has a
specific purpose and triggers different stages of the CI/CD pipeline.

## Branch Types

### main
- **Purpose:** Production-ready code only
- **Protected:** Yes — changes only via pull request from release branches
- **Pipeline:** Triggers full pipeline with manual approval gate before 
  deploying to production
- **When to use:** Never commit directly. Only merge from release branches
  after staging validation is complete.

### develop
- **Purpose:** Integration branch for completed features
- **Protected:** Yes — changes only via pull request from feature branches
- **Pipeline:** Triggers full pipeline and automatically deploys to dev 
  Kubernetes namespace
- **When to use:** Never commit directly. Merge feature branches here after
  code review and PR approval.

### feature/*
- **Purpose:** Development of new features or bug fixes
- **Protected:** No
- **Pipeline:** Triggers PR Validation pipeline (build, test, security scan)
  when a pull request is opened against develop
- **When to use:** Create from develop for every new feature or fix.
  Name descriptively: feature/add-health-endpoint, feature/fix-db-connection
- **Lifecycle:** Delete after merging to develop

### release/*
- **Purpose:** Stabilization and final testing before production
- **Protected:** No
- **Pipeline:** Triggers full pipeline and automatically deploys to staging
  Kubernetes namespace
- **When to use:** Create from develop when a set of features is ready for
  release. Name with version: release/v1.0.0, release/v1.1.0
- **Lifecycle:** Merge to main after staging validation, then delete

### hotfix/* (future use)
- **Purpose:** Emergency fixes to production
- **Protected:** No
- **Pipeline:** Same as release branches — deploys to staging for quick
  validation before production
- **When to use:** Create from main when a critical bug is found in
  production that cannot wait for the normal release cycle
- **Lifecycle:** Merge to both main and develop, then delete

## Commands

### Start a new feature
```bash
git switch develop
git pull origin develop
git checkout -b feature/your-feature-name
```

### Create a release
```bash
git switch develop
git pull origin develop
git checkout -b release/v1.0.0
git push origin release/v1.0.0
```

### Merge release to production
```bash
# Open a Pull Request on GitHub from release/v1.0.0 to main
# Approve the Jenkins production deployment gate
# Delete the release branch after merge
git push origin --delete release/v1.0.0
```

https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow