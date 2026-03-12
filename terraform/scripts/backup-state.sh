#!/bin/bash
BACKUP_DIR="backups/$(date +%Y-%m-%d_%H-%M-%S)"
mkdir -p $BACKUP_DIR

for workspace in dev staging prod; do
    if [ -f "workspaces/${workspace}/terraform.tfstate" ]; then
        mkdir -p "$BACKUP_DIR/${workspace}"
        cp "workspaces/${workspace}/terraform.tfstate" "$BACKUP_DIR/${workspace}/terraform.tfstate"
        echo "Backed up ${workspace} state to $BACKUP_DIR/${workspace}"
    else
        echo "No state file found for ${workspace}, skipping"
    fi
done

echo "Backup complete: $BACKUP_DIR"