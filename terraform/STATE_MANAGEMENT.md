# Terraform State Management

## Overview
This project uses a local Terraform backend with state locking.
State files are stored in the `workspaces/` directory with a
separate state file per environment.

## State File Locations
dev : `workspaces/dev.tfstate` 
staging : `workspaces/staging.tfstate` 
prod : `workspaces/prod.tfstate` 

## Backup Procedures

### Manual Backup
Run the backup script before any significant infrastructure changes:
```bash
./scripts/backup-state.sh
```

### What Gets Backed Up
- All environment state files (dev, staging, prod)
- Backups are timestamped and stored in `backups/`

## Recovery Procedures

### Restore from Backup
```bash
# List available backups
ls -la backups/

# Restore a specific environment
cp backups/2026-03-11_10-00-00/dev.tfstate workspaces/dev.tfstate

# Verify state is intact
terraform workspace select dev
terraform plan
```

### State Corruption
If state becomes corrupted:
1. Do not run `terraform apply`
2. Restore from most recent backup
3. Run `terraform plan` to verify state matches infrastructure
4. If no backup exists, use `terraform import` to rebuild state

## Important Notes
- State files contain sensitive data and are gitignored
- Always back up state before running `terraform destroy`
- Never manually edit state files directly
- Use `terraform state` commands to manipulate state safely


## Retrieving Outputs for Pipeline Configuration

### View all outputs
```bash
terraform workspace select dev
terraform output
```

### View a specific output
```bash
terraform output jenkins_url
terraform output cluster_endpoint
terraform output postgres_service_name
```

### View sensitive outputs
```bash
terraform output database_url
```

### Export outputs for use in Jenkins pipelines
```bash
# Export all outputs to a JSON file
terraform output -json > pipeline-config.json

# Use in shell scripts
JENKINS_URL=$(terraform output -raw jenkins_url)
CLUSTER_ENDPOINT=$(terraform output -raw cluster_endpoint)
```

### Outputs per environment
```bash
# Dev outputs
terraform workspace select dev
terraform output

# Staging outputs
terraform workspace select staging
terraform output

# Prod outputs
terraform workspace select prod
terraform output
```