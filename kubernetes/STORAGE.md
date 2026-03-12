# Local Storage Configuration

## Overview
This project uses Kubernetes PersistentVolumes with hostPath storage
for local Minikube development. Data is stored on the Minikube VM's
filesystem.

## Storage Paths

| Service | PV Name | Host Path | Size |
|---------|---------|-----------|------|
| Database | database-pv | /mnt/data/postgres | 1Gi |
| Jenkins | jenkins-pv | /mnt/data/jenkins | 2Gi |

## PersistentVolumeClaims

| Namespace | PVC Name | Bound PV | Size |
|-----------|---------|----------|------|
| dev | database-pvc | database-pv | 1Gi |
| jenkins | jenkins-pvc | jenkins-pv | 2Gi |

## Notes
- hostPath storage is for local development only
- Data is stored on the Minikube VM, not the host Mac
- Storage is lost if Minikube is deleted with `minikube delete`

## Backup Procedures
To back up database data before deleting Minikube:
```bash
kubectl exec -it $(kubectl get pod -l app=database -n dev \
  -o jsonpath='{.items[0].metadata.name}') -n dev \
  -- pg_dump -U admin ecommerce > backup.sql
```

To restore:
```bash
kubectl exec -it $(kubectl get pod -l app=database -n dev \
  -o jsonpath='{.items[0].metadata.name}') -n dev \
  -- psql -U admin ecommerce < backup.sql
```