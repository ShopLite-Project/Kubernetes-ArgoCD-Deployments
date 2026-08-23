# ShopLite Sandbox Environment

This sandbox environment is the local-first deployment lane for ShopLite on `kind` or `minikube`.

## Components

- `AppProject`: `shoplite-apps`
- `Applications`:
  - `shoplite-sandbox-configmaps`
  - `shoplite-product-service-sandbox`
  - `shoplite-order-service-sandbox`
  - `shoplite-inventory-service-sandbox`
  - `shoplite-notification-service-sandbox`
  - `shoplite-frontend-sandbox`
- Helm chart source: `helm-charts/applications/helm-master-chart`
- ConfigMap chart source: `helm-charts/applications/configmaps/shoplite/shoplite-sandbox-cm`
- Values files:
  - `environments/sandbox/applications/shoplite/shoplite-frontend/values.yaml`
  - `environments/sandbox/applications/shoplite/shoplite-product-service/values.yaml`
  - `environments/sandbox/applications/shoplite/shoplite-order-service/values.yaml`
  - `environments/sandbox/applications/shoplite/shoplite-inventory-service/values.yaml`
  - `environments/sandbox/applications/shoplite/shoplite-notification-service/values.yaml`

## Namespace

- `shoplite-sandbox`

## Image update path

Sandbox uses locally built images loaded into the cluster rather than GHCR. The application values expect:

- `shoplite-product-service:sandbox-local`
- `shoplite-order-service:sandbox-local`
- `shoplite-inventory-service:sandbox-local`
- `shoplite-notification-service:sandbox-local`
- `shoplite-frontend-service:sandbox-local`

For `kind`, build the images locally and load them with `kind load docker-image`.

ArgoCD first applies the sandbox configmaps, then renders the Helm chart with the local-first values files, and applies the result to the cluster.

## Local Runbook

Run these steps from the workspace root when using the local-first sandbox lane.

### 1. Build local images

```bash
docker build -t shoplite-product-service:sandbox-local ./ShopLite-product-service
docker build -t shoplite-order-service:sandbox-local ./ShopLite-order-service
docker build -t shoplite-inventory-service:sandbox-local ./ShopLite-inventory-service
docker build -t shoplite-notification-service:sandbox-local ./ShopLite-notification-service
docker build -t shoplite-frontend-service:sandbox-local ./ShopLite-frontend-service
```

### 2. Confirm the kind cluster name

Do not assume the cluster name is `shoplite-local`.

```bash
kind get clusters
kubectl config current-context
```

Use the actual cluster name returned by `kind get clusters` in the next step.

### 3. Load the images into kind

Replace `<cluster-name>` with the real kind cluster name.

```bash
kind load docker-image shoplite-product-service:sandbox-local --name <cluster-name>
kind load docker-image shoplite-order-service:sandbox-local --name <cluster-name>
kind load docker-image shoplite-inventory-service:sandbox-local --name <cluster-name>
kind load docker-image shoplite-notification-service:sandbox-local --name <cluster-name>
kind load docker-image shoplite-frontend-service:sandbox-local --name <cluster-name>
```

### 4. Resync the sandbox applications in ArgoCD

After the images are loaded, resync these applications:

- `shoplite-sandbox-configmaps`
- `shoplite-product-service-sandbox`
- `shoplite-order-service-sandbox`
- `shoplite-inventory-service-sandbox`
- `shoplite-notification-service-sandbox`
- `shoplite-frontend-sandbox`

You can resync from the ArgoCD UI or with the ArgoCD CLI if it is already configured.

### 5. Verify workloads

```bash
kubectl get pods -n shoplite-sandbox
kubectl get deployments -n shoplite-sandbox
kubectl get svc -n shoplite-sandbox
```

If pods still show image pull errors after sync, confirm the image tag and cluster name match the values files and the `kind load docker-image` commands exactly.

## Platform posture

- ingress remains optional for the first local pass
- `cert-manager`, `external-dns`, and `traefik` remain disabled in the sandbox platform app set
- Kafka remains disabled until the direct HTTP workflow is stable
