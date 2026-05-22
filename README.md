# k8s-ArgoCD-deployment-project

This repository stores the Kubernetes and ArgoCD deployment configuration for the ShopLite demo.

The direction behind this layout is:
- core platform components such as Traefik, cert-manager, External DNS, and ArgoCD should be provisioned with Terraform
- application deployment is handled through Helm and ArgoCD
- Moving from Kustomize-heavy and manual approach in favor of repeatable GitOps redeployments

## Repository structure

```text
k8s-ArgoCD-deployment-project/
  helm-charts/
    platforms-tools/
      argocd-application/
      argocd-project/
    applications/
      helm-master-chart/
        Chart.yaml
        values.yaml
        templates/
  environments/
    stage/
      applications/
        configmaps/
          shoplite/
            shoplite-stage-cm/
        shoplite/
          shoplite-frontend/
          shoplite-product-service/
            values.yaml
      argocd-applications/
        platforms-tools.yaml
        shoplite-stage-cm.yaml
        shoplite-stage.yaml
      argocd-project/
        projects.yaml
        platform-tools.yaml
        shoplite.yaml
      docs/
        shoplite.md
      platforms-tools/
        argocd/
        cert-manager/
        external-dns/
        traefik/
    sandbox/
    production/
```

## Simple architecture

There are four moving parts:

1. The application source repo builds and pushes the container image.
2. The CI/CD pipeline updates the Helm values file in this repo.
3. ArgoCD App-of-Apps values in `environments/stage/argocd-applications/` describe what ArgoCD should manage.
4. ArgoCD watches this repo, renders the Helm charts, and deploys the change into Kubernetes.

Terraform sits underneath that flow and is responsible for the shared cluster platform foundation, not the application release itself.

## Deployment flow

The deployment flow is:

1. Code is pushed to `ShopLite-product-service`.
2. The CI/CD workflow runs tests, security scans, and Docker build steps.
3. The workflow pushes a new image tag, for example `stage-<sha>`.
4. The workflow updates `environments/stage/applications/shoplite/shoplite-product-service/values.yaml` in this repository.
5. ArgoCD detects the Git change in this repository.
6. ArgoCD uses `environments/stage/argocd-applications/shoplite-stage.yaml` to know which ShopLite services to manage.
7. ArgoCD renders `helm-charts/applications/helm-master-chart` with the relevant stage values file.
8. ArgoCD syncs the target application into the `shoplite-stage` namespace.
9. Kubernetes pulls the new image and rolls out the updated pod.

## What lives where

- `helm-charts/applications/helm-master-chart/`
  Contains the reusable Helm chart used to render the ShopLite service resources.

- `helm-charts/platforms-tools/argocd-application/`
  Contains the Helm chart that renders ArgoCD `Application` resources from values files such as `shoplite-stage.yaml` and `platforms-tools.yaml`.

- `helm-charts/platforms-tools/argocd-project/`
  Contains the Helm chart that renders ArgoCD `AppProject` resources.

- `environments/stage/argocd-project/`
  Defines the ArgoCD project that controls what repos and namespaces are allowed.

- `environments/stage/argocd-applications/`
  Holds the App-of-Apps values for ShopLite services and platform tools.

- `environments/stage/applications/`
  Holds environment-specific Helm values for the ShopLite services.

- `environments/stage/platforms-tools/`
  Holds reference values for core platform components such as Traefik, cert-manager, External DNS, and Argo CD.

- `environments/stage/docs/`
  Holds small notes for operators and reviewers.

## Current stage setup

The current stage environment includes:

- `shoplite-frontend`
- `shoplite-product-service`
- `shoplite-order-service`
- `shoplite-inventory-service`
- `shoplite-notification-service`

These are rendered from the shared Helm chart and deployed into `shoplite-stage`.

Stage configmaps are deployed first from:

- `helm-charts/applications/configmaps/shoplite/shoplite-stage-cm`

and provide:

- `shoplite-global-config`
- `shoplite-stage-config`
- one service-specific configmap per ShopLite service

The stage repo structure also includes `platforms-tools.yaml` plus stage values for:

- `cert-manager`
- `external-dns`
- `traefik`
- `argocd`

These platform components are documented in the same structure for learning consistency, but they are disabled in ArgoCD by default because the current platform strategy provisions them with Terraform.

Kafka can follow the same platform-tools model:

- the Kafka operator belongs in `environments/<env>/platforms-tools/`
- ArgoCD can install the operator as a platform tool
- Kafka cluster and topic resources can be rendered from a local Helm chart after the operator exists
- service repos should only contain Kafka client code, not Kafka cluster installation logic

## Roadmap

A project progression as the reference path:

### Phase 1

- reusable actions for CI/CD
- Docker image build and push
- Helm-based application deployment
- Argo CD App-of-Apps structure
- Terraform-aligned platform layout
- ShopLite stage configmaps
- frontend plus backend services

### Phase 2

- separate configuration repo for configmaps and environment config
- separate secrets or Vault integration repo/workflow
- ingress and DNS wiring for the frontend
- service-to-service runtime configuration cleanup
- optional enabling of Argo CD-managed platform tools where appropriate

### Phase 3

- PostgreSQL for persistent order data
- Redis for caching or fast state access
- Kafka for asynchronous event flow and operator-managed platform learning
- observability stack integration
- autoscaling, policies, and more production-like platform controls

## Do we need separate configuration and Vault repos?

Not immediately.

For this stage of the project, keeping configuration in this k8s repo is acceptable because:

- it keeps the learning path simple
- you can validate Helm, Argo CD, and CI/CD without adding cross-repo complexity
- the platform flow is easier to explain on LinkedIn while the system is still small

You should consider splitting later when:

- multiple applications share the same environment config
- secrets must be managed outside Git
- you want a closer match to the Plateng model
- different teams own application code, config, and secrets separately

Recommended direction:

- keep this repo as the GitOps deployment repo for now
- add a dedicated `shoplite-configuration` repo in Phase 2
- use Vault or a `shoplite-vault-config` style repo only when you are ready to model real secret delivery

## Notes

- The image tag in `environments/stage/applications/shoplite/shoplite-product-service/values.yaml` is the value updated by CI/CD.
- ArgoCD should be configured to watch this repository on the branch referenced in the Application manifest.
- `sandbox` and `production` are placeholders until you are ready to model those environments.
