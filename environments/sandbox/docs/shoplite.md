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

## Platform posture

- ingress remains optional for the first local pass
- `cert-manager`, `external-dns`, and `traefik` remain disabled in the sandbox platform app set
- Kafka remains disabled until the direct HTTP workflow is stable
