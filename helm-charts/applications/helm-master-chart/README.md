# Master Helm Chart

A reusable, generic Helm chart for deploying any application to Kubernetes.

## Features

- Deployment with configurable replicas, resources, and probes
- Service (ClusterIP, NodePort, LoadBalancer)
- Ingress with TLS support
- Horizontal Pod Autoscaler (HPA)
- Pod Disruption Budget (PDB)
- ConfigMap and Secret management
- Persistent Volume Claims
- Network Policies
- Prometheus ServiceMonitor
- Init containers and sidecars support
- Custom extra manifests

## Quick Start

```bash
# Install with default values
helm install my-app ./helm-master

# Install with custom values file
helm install my-app ./helm-master -f my-values.yaml

# Install with inline overrides
helm install my-app ./helm-master \
  --set image.repository=nginx \
  --set image.tag=1.21 \
  --set replicaCount=3
```

## Configuration

### Basic Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `name` | Application name | `my-app` |
| `namespace` | Kubernetes namespace | `default` |
| `replicaCount` | Number of replicas | `1` |

### Image Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Container image repository | `nginx` |
| `image.tag` | Container image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Image pull secrets | `[]` |

### Container Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `containerPort` | Container port | `80` |
| `command` | Container command | `[]` |
| `args` | Container arguments | `[]` |
| `env` | Environment variables | `[]` |
| `envFrom` | Environment from ConfigMap/Secret | `[]` |

### Resources

```yaml
resources:
  limits:
    cpu: 500m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

### Health Probes

```yaml
livenessProbe:
  enabled: true
  httpGet:
    path: /health
    port: http
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  enabled: true
  httpGet:
    path: /ready
    port: http
  initialDelaySeconds: 10
  periodSeconds: 5

startupProbe:
  enabled: false
  httpGet:
    path: /health
    port: http
  failureThreshold: 30
```

### Service

```yaml
service:
  enabled: true
  type: ClusterIP  # ClusterIP, NodePort, LoadBalancer
  port: 80
  targetPort: 80
  annotations: {}
  additionalPorts: []
```

### Ingress

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    kubernetes.io/tls-acme: "true"
  hosts:
    - host: app.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: app-tls
      hosts:
        - app.example.com
```

### Autoscaling (HPA)

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 80
```

### Pod Disruption Budget

```yaml
podDisruptionBudget:
  enabled: true
  minAvailable: 1
  # maxUnavailable: 1
```

### ConfigMap

```yaml
configMap:
  enabled: true
  data:
    APP_ENV: production
    LOG_LEVEL: info
```

### Secret

```yaml
secret:
  enabled: true
  type: Opaque
  stringData:
    API_KEY: my-secret-key
```

### Persistence

```yaml
persistence:
  enabled: true
  storageClass: standard
  accessModes:
    - ReadWriteOnce
  size: 10Gi
```

### Network Policy

```yaml
networkPolicy:
  enabled: true
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: allowed-namespace
```

### Prometheus ServiceMonitor

```yaml
serviceMonitor:
  enabled: true
  interval: 30s
  path: /metrics
  port: http
```

### Init Containers

```yaml
initContainers:
  - name: init-db
    image: busybox:1.28
    command: ['sh', '-c', 'echo waiting for db && sleep 10']
```

### Sidecar Containers

```yaml
sidecarContainers:
  - name: log-shipper
    image: fluent/fluent-bit
    volumeMounts:
      - name: logs
        mountPath: /var/log
```

### Volumes

```yaml
volumes:
  - name: config
    configMap:
      name: my-config

volumeMounts:
  - name: config
    mountPath: /etc/config
```

### Extra Manifests

Deploy additional Kubernetes resources:

```yaml
extraManifests:
  - apiVersion: v1
    kind: ConfigMap
    metadata:
      name: extra-config
    data:
      key: value
```

## Examples

### Deploy a Web Application

```yaml
# web-app-values.yaml
name: web-app
namespace: production

image:
  repository: myregistry/web-app
  tag: v1.2.3

replicaCount: 3

containerPort: 8080

service:
  enabled: true
  port: 80
  targetPort: 8080

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: webapp.example.com
      paths:
        - path: /
          pathType: Prefix

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70

resources:
  limits:
    cpu: 1000m
    memory: 512Mi
  requests:
    cpu: 200m
    memory: 256Mi
```

```bash
helm install web-app ./helm-master -f web-app-values.yaml
```

### Deploy a Backend API

```yaml
# api-values.yaml
name: backend-api
namespace: default

image:
  repository: myregistry/api
  tag: latest

containerPort: 3000

env:
  - name: NODE_ENV
    value: production
  - name: DB_HOST
    valueFrom:
      secretKeyRef:
        name: db-credentials
        key: host

livenessProbe:
  httpGet:
    path: /api/health
    port: http

readinessProbe:
  httpGet:
    path: /api/ready
    port: http

service:
  enabled: true
  port: 80
  targetPort: 3000
```

### Deploy a Worker/Background Job

```yaml
# worker-values.yaml
name: background-worker
namespace: default

image:
  repository: myregistry/worker
  tag: v1.0.0

replicaCount: 2

command: ["python"]
args: ["worker.py", "--queue=default"]

service:
  enabled: false

livenessProbe:
  enabled: false

readinessProbe:
  enabled: false

resources:
  limits:
    cpu: 500m
    memory: 1Gi
  requests:
    cpu: 100m
    memory: 256Mi
```

## Commands

```bash
# Install
helm install <release-name> ./helm-master -f values.yaml

# Upgrade
helm upgrade <release-name> ./helm-master -f values.yaml

# Uninstall
helm uninstall <release-name>

# Dry run (preview)
helm install <release-name> ./helm-master -f values.yaml --dry-run

# Template (render locally)
helm template <release-name> ./helm-master -f values.yaml

# Lint
helm lint ./helm-master
```

## License

MIT
