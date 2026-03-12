# Deployment Strategy

## Overview
This project uses a Rolling Update deployment strategy for all 4 
microservices. This ensures zero downtime during deployments by 
gradually replacing old pods with new ones.

## Rolling Update Configuration
All deployments are configured with the following rolling update strategy:
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0
```

### Configuration Explained
- **maxSurge: 1** — allows one extra pod above the desired replica count 
  during updates, so a new pod is created before the old one is terminated
- **maxUnavailable: 0** — ensures no pods are unavailable during the update,
  guaranteeing zero downtime

## Deployment Flow
```
Old Pod Running (v1)
       ↓
New Pod Created (v2) ← maxSurge allows this
       ↓
New Pod passes readiness probe
       ↓
Old Pod terminated
       ↓
Rollout complete
```

## Per Service Strategy

| Service | Replicas | Max Surge | Max Unavailable |
|---------|----------|-----------|-----------------|
| ecommerce-frontend | 1 | 1 | 0 |
| product-service | 1 | 1 | 0 |
| order-service | 1 | 1 | 0 |
| database | 1 | 1 | 0 |

## Health Checks
Readiness and liveness probes ensure traffic is only routed to 
healthy pods during rollouts:

- **Readiness Probe** — determines when a pod is ready to receive traffic
- **Liveness Probe** — determines if a pod needs to be restarted

## Rollback Procedure
If a deployment fails, roll back to the previous version:
```bash
# Roll back a specific deployment
kubectl rollout undo deployment/product-service -n dev

# Roll back to a specific revision
kubectl rollout undo deployment/product-service -n dev --to-revision=2

# Check rollout history
kubectl rollout history deployment/product-service -n dev
```

### Rolling Updates — Why I Chose It
- Zero downtime deployments
- Lower resource requirements than blue-green
- Built into Kubernetes natively with no extra tooling
- Automatic rollback on failed health checks
- Appropriate for a microservices architecture with independent services