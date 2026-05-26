# ShopLite Stage Environment

This stage environment is the cloud-oriented deployment lane for ShopLite.

## Components

- `AppProject`: `shoplite-apps`
- `Applications`:
  - `shoplite-stage-configmaps`
  - `shoplite-product-service-stage`
  - `shoplite-order-service-stage`
  - `shoplite-inventory-service-stage`
  - `shoplite-notification-service-stage`
  - `shoplite-frontend-stage`
- Helm chart source: `helm-charts/applications/helm-master-chart`
- ConfigMap chart source: `helm-charts/applications/configmaps/shoplite/shoplite-stage-cm`
- Values files:
  - `environments/stage/applications/shoplite/shoplite-frontend/values.yaml`
  - `environments/stage/applications/shoplite/shoplite-product-service/values.yaml`
  - `environments/stage/applications/shoplite/shoplite-order-service/values.yaml`
  - `environments/stage/applications/shoplite/shoplite-inventory-service/values.yaml`
  - `environments/stage/applications/shoplite/shoplite-notification-service/values.yaml`

## Namespace

- `shoplite-stage`

## Image update path

The stage lane is intended for registry-backed images and cloud infrastructure. Service values use GHCR images with `stage-latest` tags by default, while local clusters should stay on the sandbox lane with locally built images.

## Platform posture

- `cert-manager`, `external-dns`, and `traefik` are enabled in the stage platform app set
- Kafka remains disabled until the direct HTTP workflow is stable end-to-end
