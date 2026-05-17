# ShopLite Sandbox Environment

This sandbox environment deploys the ShopLite application services through ArgoCD and Helm.

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

The product service CI/CD pipeline updates:

- `environments/sandbox/applications/shoplite/shoplite-product-service/values.yaml`

ArgoCD first applies the sandbox configmaps, then renders the Helm chart with the updated values files, and applies the result to the cluster.
