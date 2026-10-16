<p align="center">
  <img src="https://raw.githubusercontent.com/felixZmn/feedBox/main/feedBox/src/main/resources/META-INF/resources/icons/package.svg" alt="FeedBox Logo" width="100"/>
</p>

<h1 align="center">FeedBox Helm Chart</h1>
<h3 align="center">Put all your feeds into a box!</h3>

<p align="center">
  <!-- CI -->
  <a href="https://github.com/felixzmn/feedbox-chart/actions/workflows/ci.yml">
    <img src="https://github.com/felixzmn/feedbox-chart/actions/workflows/ci.yml/badge.svg" alt="CI Status"/>
  </a>
  <!-- Release -->
  <a href="https://github.com/felixzmn/feedbox-chart/actions/workflows/release.yml">
    <img src="https://github.com/felixzmn/feedbox-chart/actions/workflows/release.yml/badge.svg" alt="Release Status"/>
  </a>
  <!-- Latest Release -->
  <a href="https://github.com/felixzmn/feedbox-chart/releases">
    <img src="https://img.shields.io/github/v/release/felixzmn/feedbox-chart?logo=github" alt="Latest Release"/>
  </a>
  <!-- Helm Chart OCI -->
  <a href="https://ghcr.io/felixzmn/helm/feedbox">
    <img src="https://img.shields.io/badge/helm-chart-blue?logo=helm" alt="Helm Chart"/>
  </a>
  <!-- App -->
  <a href="https://github.com/felixZmn/feedBox">
    <img src="https://img.shields.io/badge/app-feedBox-informational" alt="FeedBox app"/>
  </a>
</p>

Helm chart for deploying **FeedBox**.

## Chart repository

This chart is published as an OCI artifact to GitHub Container Registry:

```bash
oci://ghcr.io/felixzmn/helm
```

## Installation

```bash
helm install feedbox oci://ghcr.io/felixzmn/helm/feedbox --version <version> \
  --set database.dbSecretName=<jdbc-secret> \
  --set sso.authServerUrl=<idp-issuer> \
  --set sso.clientId=<client-id> \
  --set sso.encryptionSecret=<32+-char-secret> \
  --set sso.buttonLabel='Sign in with Authentik'
```

Example:

```bash
helm install feedbox oci://ghcr.io/felixzmn/helm/feedbox --version 4.0.0 \
  --set database.dbSecretName=feedbox-pguser \
  --set sso.authServerUrl=https://idp.example/application/o/feedbox/ \
  --set sso.clientId=feedbox \
  --set sso.encryptionSecret='please-change-me-to-32-chars-min' \
  --set sso.buttonLabel='Sign in with Authentik'
```

`encryptionSecret` / `clientSecret` are written into a chart-managed Kubernetes Secret and mounted via `secretKeyRef` (not plain Deployment env). Prefer `sso.existingSecret` in production.

### Breaking change (4.0.0)

Chart **4.0.0** is the SemVer-correct release for the Quarkus OIDC web-app switch.
Values from ≤3.6.x (`jwtPublicKeyLocation`, `redirectUri`, `secretRef`, …) are not compatible.
The interim **3.7.x / 3.8.x** chart versions carried that break under a minor bump by mistake — use **4.0.0**.

Ingress and HTTPRoute both default to **disabled**. Enable one explicitly if you need external routing.

## Key values

| Value | Default | Notes |
|-------|---------|--------|
| `database.dbSecretName` | `""` (required) | Secret name with JDBC URL |
| `database.jdbcUrlKey` | `jdbc-uri` | Key inside that secret |
| `ingress.enabled` | `false` | Classic Ingress |
| `httpRoute.enabled` | `false` | Gateway API HTTPRoute |
| `sso.enabled` | `true` | Quarkus OIDC web-app |
| `sso.buttonLabel` | `Sign in with SSO` | Login-panel button text |
| `sso.existingSecret` | `""` | Use an existing Secret instead of chart-managed |
| `sso.encryptionSecret` | `""` | 32+ chars when `existingSecret` is empty |
| `config.app.http.user-agent` | *(unset)* | App default is `FeedBox/<version>` |

## Upgrade

```bash
helm upgrade feedbox oci://ghcr.io/felixzmn/helm/feedbox --version <version>
```

## Pull chart locally

```bash
helm pull oci://ghcr.io/felixzmn/helm/feedbox --version <version>
```

## Development

Validate the chart locally:

```bash
helm lint .
helm template feedbox . > /dev/null
```

Package manually if needed:

```bash
helm package .
```

Push manually if needed:

```bash
helm push feedbox-*.tgz oci://ghcr.io/felixzmn/helm
```

## Release process

Chart releases are driven by `Chart.yaml` `version` on `main`. After merge, the release workflow creates the matching git tag, pushes the OCI chart to GHCR, and creates a GitHub Release.

| Change | Who | What happens |
|--------|-----|----------------|
| App image patch/minor | Renovate (automerge) | Updates `appVersion`, bumps chart `version`, merges → release |
| App image major | You merge the Renovate PR | Same publish path after merge |
| Chart feature / breaking | You bump `version` in the PR and merge | Release on merge |

### Feature / manual chart change

1. Edit templates/values as needed
2. Bump `version` in `Chart.yaml` (and `appVersion` only if the app image changed)
3. Open a PR — CI runs `helm lint` / `helm template`
4. Merge to `main` → release workflow publishes

### What the release workflow does

- skips if a git tag for the current chart `version` already exists
- runs `helm lint` and `helm template`
- creates annotated tag `$version`
- packages and pushes to `oci://ghcr.io/felixzmn/helm`
- creates a GitHub Release

### Required secrets

- `RENOVATE_PAT` — for the Renovate workflow
- `GHCR_TOKEN` — so Renovate can read `ghcr.io/felixzmn/docker/feedbox` tags

Also protect `main` and require the **CI** check so Renovate only automerges green PRs.

## CI

The CI workflow runs on pull requests and performs:

- `helm lint .`
- `helm template <chart-name> .`

## Versioning

- `version` in `Chart.yaml` is the **chart version** (release tag / OCI chart version)
- `appVersion` in `Chart.yaml` is the **application image tag** (used when `image.tag` is empty)
