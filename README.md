[![CI](https://github.com/observIQ/bindplane-op-helm/actions/workflows/ci.yml/badge.svg)](https://github.com/observIQ/bindplane-op-helm/actions/workflows/ci.yml)
[![Helm Release](https://github.com/observIQ/bindplane-op-helm/actions/workflows/helm.yml/badge.svg)](https://github.com/observIQ/bindplane-op-helm/actions/workflows/helm.yml)
[![Pages Deployment](https://github.com/observIQ/bindplane-op-helm/actions/workflows/pages/pages-build-deployment/badge.svg)](https://github.com/observIQ/bindplane-op-helm/actions/workflows/pages/pages-build-deployment)

# BindPlane OP Helm

This repository contains a Helm chart for [BindPlane OP](https://github.com/observIQ/bindplane-op).

## Prerequisites

### Helm

[Helm](https://helm.sh) must be installed to use the charts. Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

### Secrets

The Chart can accept a secret for configuring sensative options. This secret should be managed outside of helm with your preferred secret management solution. Alternatively, you can specify
these options using a values file. See the [Chart documentation](./charts/bindplane/README.md).

The secret should have the following keys:
- `username`: Basic auth username to use for the default admin user
- `password`: Basic auth password to use for the default admin user
- `secret_key`: Random UUIDv4 to use for authenticating OpAMP clients
- `sessions_secret`: Random UUIDv4 used to derive web interface session tokens

Example: Create secret with `kubectl`:

```shell
kubectl -n default create secret generic bindplane \
  --from-literal=username=myuser \
  --from-literal=password=mypassword \
  --from-literal=secret_key=353753ca-ae48-40f9-9588-28cf86430910 \
  --from-literal=sessions_secret=d9425db6-c4ee-4769-9c1f-a66987679e90
```

## Configuration

See the [Chart documentation](./charts/bindplane/README.md) for configuration documentation.

## Usage

Add the repository:

```bash
helm repo add bindplane \
    https://observiq.github.io/bindplane-op-helm

helm repo update
helm search repo
```

Install

```bash
helm upgrade --install bindplane bindplane/bindplane
```

## Connectivity

BindPlane can be reached using the clusterIP service deployed by the chart. By default the service
name is `bindplane` and the port is `3001`.

**Web Interface**

You can connect to BindPlane from your workstation using port forwarding:

```bash
kubectl -n default port-forward svc/bindplane 3001
```

You should now be able to access http://localhost:3001

**Command Line**

You can connect to BindPlane from your workstation using port forwarding:

```bash
kubectl -n default port-forward svc/bindplane 3001
```

Create and use a profile:

```bash
bindplanectl profile set myprofile \
  --username <username> \
  --password <password> \
  --server-url http://localhost:3001

bindplanectl profile use myprofile
```

You should be able to issue commands: `bindplanectl get agent`

**Collectors**

Collectors running within the cluster can connect with the following OpAMP URI:

```
ws://bindplane.default.svc.cluster.local:3001/v1/opamp
```

# Community

BindPlane OP Helm is an open source project. If you'd like to contribute, take a look at our [contribution guidelines](/docs/CONTRIBUTING.md). We look forward to building with you.

## Code of Conduct

BindPlane OP Helm follows the [CNCF Code of Conduct](https://github.com/cncf/foundation/blob/master/code-of-conduct.md). Please report violations of the Code of Conduct to any or all [maintainers](/docs/MAINTAINERS.md).

# Other questions?

Send us an [email](mailto:support@observiq.com), or open an issue with your question. We'd love to hear from you!