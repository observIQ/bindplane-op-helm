# bindplane

![Version: 1.11.8](https://img.shields.io/badge/Version-1.11.8-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.62.0](https://img.shields.io/badge/AppVersion-1.62.0-informational?style=flat-square)

BindPlane OP is an observability pipeline.

**Homepage:** <https://github.com/observIQ/bindplane-op>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| jsirianni | <joe.sirianni@observiq.com> |  |

## Source Code

* <https://github.com/observIQ/bindplane-op/>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| auth.google.clientid | string | `""` | Google OAUTH clientid |
| auth.ldap.baseDN | string | `""` | Base DN to use when looking up users. Example: `ou=users,dc=stage,dc=net`. |
| auth.ldap.bindPassword | string | `""` | Password to use for the bind user. |
| auth.ldap.bindUser | string | `""` | User to use when looking up users. Example: `cn=admin,dc=stage,dc=net.` |
| auth.ldap.port | string | `nil` | TCP port to use when connecting to the ldap server. Defaults to `1389` (plain text) or `1636` (tls). |
| auth.ldap.protocol | string | `"ldap"` | Protocol to use. Available options include `ldap` (plain text) and `ldaps` (tls). |
| auth.ldap.searchFilter | string | `""` | Search filter to use when looking up users. Defaults to `(uid=%s)` (ldap) and `(|(sAMAccountName=%[1]v)(userPrincipalName=%[1]v))` (active-directory). |
| auth.ldap.server | string | `""` | Hostname or IP address of the ldap server. |
| auth.ldap.tls.ca.secret | string | `""` | Name of the Kubernetes secret which contains the ldap server's certificate authority public certificate. |
| auth.ldap.tls.ca.subPath | string | `""` | The secret's subPath which contains the certificate. |
| auth.ldap.tls.clientKeyPair.crtSubPath | string | `""` | The secret's subPath which contains the client certificate. |
| auth.ldap.tls.clientKeyPair.keySubPath | string | `""` | The secret's subPath which contains the client private key. |
| auth.ldap.tls.clientKeyPair.secret | string | `""` | Name of the Kubernetes secret which contains the ldap client keypair. This can be the same secret as `auth.ldap.ca.secret` as long as it has the client certificate and key. |
| auth.ldap.tls.insecure | bool | `false` | Whether or not to skip verification of the ldap server's certificate. |
| auth.type | string | `"system"` | Backend to use for authentication. Available options include `system`, `ldap`, `active-directory`, and `google`. |
| autoscaling.enable | bool | `false` | Whether or not autoscaling should be enabled. Requires an eventbus to be configured. |
| autoscaling.max | int | `10` | Maximum number of pods when autoscaling is enabled. |
| autoscaling.min | int | `2` | Minimum number of pods when autoscaling is enabled. |
| autoscaling.targetCPUUtilizationPercentage | int | `60` | Autoscaling target CPU usage percentage. |
| autoscaling.targetMemoryUtilizationPercentage | int | `60` | Autoscaling target Memory usage percentage. |
| backend.bbolt.storageClass | string | `""` | The Kubernetes storage class to use for the volumeClaimTemplate. If unset, the volume claim will use the cluster's default storage class. |
| backend.bbolt.volumeSize | string | `"10Gi"` | Persistent volume size. |
| backend.postgres.database | string | `""` | Database to use. |
| backend.postgres.host | string | `"localhost"` | Hostname or IP address of the Postgres server. |
| backend.postgres.maxConnections | int | `100` | Max number of connections to use when communicating with Postgres. |
| backend.postgres.password | string | `""` | Password for the username used to connect to Postgres. |
| backend.postgres.port | int | `5432` | TCP port used to connect to Postgres. |
| backend.postgres.sslmode | string | `"disable"` | SSL mode to use when connecting to Postgres over TLS. Supported options include "disable", "require", "verify-ca", "verify-full". See the [postgres ssl documentation](https://jdbc.postgresql.org/documentation/ssl/) for more information. |
| backend.postgres.sslsecret.name | string | `""` | Name of the secret that contains the Postgres TLS certificate(s). When SSL mode is set to `verify-ca` or `verify-full`, this secret will be used to mount certificates into the BindPlane container. Requires BindPlane v1.56.0 or newer. |
| backend.postgres.sslsecret.sslcertSubPath | string | `""` | Path to the client certificate used to authenticate with the Postgres server, when mutual TLS is required. |
| backend.postgres.sslsecret.sslkeySubPath | string | `""` | Path to the client private key used to authenticate with the Postgres server, when mutual TLS is required. Required when `sslcertSubPath` is set. |
| backend.postgres.sslsecret.sslrootcertSubPath | string | `""` | Path to the CA certificate used to verify the Postgres server's certificate. |
| backend.postgres.username | string | `""` | Username to use when connecting to Postgres. |
| backend.type | string | `"bbolt"` | Backend to use for persistent storage. Available options are `bbolt`, and `postgres`. |
| config.accept_eula | bool | `true` | Whether or not to accept the EULA. EULA acceptance is required. See https://observiq.com/legal/eula. |
| config.analytics.disable | bool | `false` | Whether or not to disable analytics. Disabling analytics is only supported when an enterprise license is used. |
| config.license | string | `""` | The license key to use for BindPlane OP. Overrides `config.secret`. |
| config.licenseUseSecret | bool | `false` | When true, the license key will be referenced from the `config.secret` secret. |
| config.password | string | `""` | Password to use. Overrides `config.secret`. |
| config.remote_url | string | `""` | URI used by agents to communicate with BindPlane using OpAMP. NOTE: This value is not used in BindPlane OP v1.15.0 and newer.  It will eventually be removed when support for older versions of BindPlane is removed from this chart. |
| config.secret | string | `"bindplane"` | Name of the Kubernetes secret which contains the `username`, `password`, `secret_key`, `sessions_secret`, and `license` configuration options. |
| config.secret_key | string | `""` | DEPRECATED: New deployments should leave this option unset. |
| config.server_url | string | `""` | URI used by clients to communicate with BindPlane. |
| config.sessions_secret | string | `""` | Sessions Secret to use. Overrides `config.secret`. |
| config.username | string | `""` | Username to use. Overrides `config.secret`. |
| containerSecurityContext | object | `{"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":65534}` | The Container's securityContext: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container. |
| dev.bindplane.auth.auth0.audience | string | `""` |  |
| dev.bindplane.auth.auth0.clientID | string | `""` |  |
| dev.bindplane.auth.auth0.domain | string | `""` |  |
| dev.namespace.create | bool | `false` |  |
| dev.namespace.name | string | `""` |  |
| dev.prometheus.create | bool | `false` |  |
| dev.prometheus.image.name | string | `"prom/prometheus"` |  |
| dev.prometheus.image.tag | string | `"v2.47.2"` |  |
| email.sendgrid.token | string | `""` | The sendgrid API token to use when authenticating to Sendgrid. |
| email.type | string | `""` | The optional email backend type to use. Valid options include `sendgrid`. Requires an auth type other than `system`. |
| eventbus.kafka.auth.plain.password | string | `""` | Password to use for plain authentication. |
| eventbus.kafka.auth.plain.username | string | `""` | Username to use for plain authentication. |
| eventbus.kafka.auth.sasl.mechanism | string | `""` | Mechanism for SASL authentication. One of plain|scramSHA256|scramSHA512. |
| eventbus.kafka.auth.sasl.password | string | `""` | Password to use for SASL authentication. |
| eventbus.kafka.auth.sasl.username | string | `""` | Username to use for SASL authentication. |
| eventbus.kafka.auth.sasl.version | string | `""` | Version of SASL authentication to use. One of 0|1". |
| eventbus.kafka.auth.type | string | `""` | How to authenticate to Kafka. One of: none|plainText|sasl. |
| eventbus.kafka.brokers | string | `""` | Comma separated list of brokers to use, in the form of `host:port`. |
| eventbus.kafka.protocolVersion | string | `""` | Protocol version of the Kafka brokers in 'MAJOR.MINOR.PATCH' format |
| eventbus.kafka.tls.enable | bool | `false` | Whether or not to use TLS when connecting to Kafka. |
| eventbus.kafka.tls.insecure | bool | `false` | Whether or not to skip verification of the Kafka broker certificate(s). |
| eventbus.kafka.tls.secret.caSubPath | string | `""` | The secret's subPath which contains the certificate authority. |
| eventbus.kafka.tls.secret.crtSubPath | string | `""` | The secret's subPath which contains the certificate for mutual TLS. |
| eventbus.kafka.tls.secret.keySubPath | string | `""` | The secret's subPath which contains the private key for mutual TLS. |
| eventbus.kafka.tls.secret.name | string | `nil` | Kubernetes TLS secret name. |
| eventbus.kafka.topic | string | `""` | Topic to use. |
| eventbus.pubsub.credentials.secret | string | `""` | Optional Kubernetes secret which contains Google Cloud JSON service account credentials. Not required when running within Google Cloud with the Pub/Sub scope enabled. |
| eventbus.pubsub.credentials.subPath | string | `""` | Sub path for the secret which contains the Google Cloud credential JSON |
| eventbus.pubsub.endpoint | string | `""` | For testing against an emulator only. |
| eventbus.pubsub.insecure | bool | `false` | For testing against an emulator only. |
| eventbus.pubsub.projectid | string | `""` |  |
| eventbus.pubsub.topic | string | `""` |  |
| eventbus.type | string | `""` |  |
| extraEnv | list | `[]` | Optional arbitrary environment variables to add to the BindPlane pod(s). |
| extraPodLabels | object | `{}` | Optional arbitrary labels to add to the BindPlane pod(s). |
| extraVolumeMounts | list | `[]` | Optional arbitrary volume mounts to add to the BindPlane pod(s). |
| extraVolumes | list | `[]` | Optional arbitrary volumes to add to the BindPlane pod(s). |
| health.livenessProbe | object | `{"httpGet":{"path":"/health","port":"http"}}` | Full configuration for livenessProbe. Supports all options documented here: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/. |
| health.readinessProbe | object | `{"httpGet":{"path":"/health","port":"http"}}` | Full configuration for readinessProbe. Supports all options documented here: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/. |
| health.startupProbe | object | `{"httpGet":{"path":"/health","port":"http"}}` | Full configuration for startupProbe. Supports all options documented here: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/. |
| image.name | string | `""` | Image name to be used. Defaults to `ghcr.io/observiq/bindplane-ee`. |
| image.tag | string | `""` | Image tag to use. Defaults to the version defined in the Chart's release. |
| ingress.annotations | object | `{}` | Custom annotations which will be added to the ingress object. Useful for specifying things such as `cert-manager.io/cluster-issuer`. |
| ingress.class | string | `nil` | Ingress class to use when ingress is enabled. |
| ingress.enable | bool | `false` | Whether or not to enable ingress. |
| ingress.host | string | `nil` | Hostname to use when ingress is enabled. |
| ingress.tls.enable | bool | `false` | Whether or not to enable ingress transport layer security (TLS). |
| ingress.tls.secret | string | `""` | Name of the Kubernetes secret which contains the TLS certificate. This secret must be created and managed outside of the Helm chart. See the [ingress TLS documentation](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls) for more details. |
| jobs.resources.limits.memory | string | `"1000Mi"` | Memory limit. |
| jobs.resources.requests.cpu | string | `"1000m"` | CPU request. |
| jobs.resources.requests.memory | string | `"1000Mi"` | Memory request. |
| multiAccount | bool | `false` | Whether or not to enable multi account (tenant). |
| podSecurityContext | object | `{"fsGroup":65534}` | The Pod spec's securityContext: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod. |
| prometheus.auth.password | string | `""` | Prometheus basic authentication password. |
| prometheus.auth.type | string | `"none"` | Prometheus authentication. Supported options include `none` and `basic`. |
| prometheus.auth.username | string | `""` | Prometheus basic authentication username. |
| prometheus.enableSideCar | bool | `false` | When enabled, the Prometheus measurements backend will be deployed as a sidecar container. This option is only valid when BindPlane is running as a single node statefulset. |
| prometheus.extraPodLabels | object | `{}` | Optional arbitrary labels to add to the Prometheus pod. This option is only used when Prometheus is running as a StatefulSet managed by the chart (The default mode). |
| prometheus.host | string | `""` | The Prometheus hostname or IP address used for querying and writing metrics. Defaults to the service name of the Prometheus StatefulSet deployed by this chart. |
| prometheus.image.name | string | `"ghcr.io/observiq/bindplane-prometheus"` | Image name to be used. Defaults to `ghcr.io/observiq/bindplane-prometheus`. NOTE: The image tag is derived from the BindPlane server tag. |
| prometheus.port | int | `9090` | The Prometheus TCP port used for querying and writing metrics. |
| prometheus.queryPathPrefix | string | `""` | Optional Prometheus query path prefix. Useful when overriding the query endpoints when using systems such as Mimir. |
| prometheus.remote | bool | `false` | When true, the chart will not deploy Prometheus. Instead, the user should provide a Prometheus instance to use. |
| prometheus.remoteWrite.host | string | `""` | Optional hostname or IP address of the remote write endpoint. This value overrides the `prometheus.host` for remote write. |
| prometheus.remoteWrite.path | string | `"/api/v1/write"` | Path of the remote write endpoint. This value should default to `/api/v1/write`. |
| prometheus.remoteWrite.port | int | `9090` | Optional TCP port of the remote write endpoint. This value overrides the `prometheus.port` for remote write. |
| prometheus.resources.limits.memory | string | `"500Mi"` | Memory limit. |
| prometheus.resources.requests.cpu | string | `"250m"` | CPU request. |
| prometheus.resources.requests.memory | string | `"500Mi"` | Memory request. |
| prometheus.storage.storageClass | string | `""` | The Kubernetes storage class to use for the volumeClaimTemplate. If unset, the volume claim will use the cluster's default storage class. |
| prometheus.storage.volumeSize | string | `"10Gi"` | Persistent volume size. |
| prometheus.tls.enable | bool | `false` | Whether or not to use TLS when connecting to Prometheus. |
| prometheus.tls.insecure | bool | `false` | Whether or not to skip verification of the Prometheus server's certificate. |
| prometheus.tls.secret.caSubPath | string | `""` | The secret's subPath which contains the certificate authority. |
| prometheus.tls.secret.crtSubPath | string | `""` | The secret's subPath which contains the client certificate, required for mutual TLS. |
| prometheus.tls.secret.keySubPath | string | `""` | The secret's subPath which contains the client private key, required for mutual TLS. |
| prometheus.tls.secret.name | string | `""` | Kubernetes TLS secret name that contains the Prometheus TLS certificate(s). |
| prometheus.tolerations | object | `{}` | Tolerations for the Prometheus pod. |
| replicas | int | `0` | Number of replicas to use for the BindPlane server. Should not be set if `autoscaling.enable` is set to `true`. 0 means this option will not be set. |
| resources.limits.memory | string | `"1000Mi"` | Memory limit. |
| resources.requests.cpu | string | `"1000m"` | CPU request. |
| resources.requests.memory | string | `"1000Mi"` | Memory request. |
| service.annotations | object | `{}` | Custom annotations which will be added to the service object. Useful for specifying things such as `cloud.google.com/backend-config`. |
| tolerations | object | `{}` | The Pod's tolerations |
| trace.otlp.endpoint | string | `""` | Endpoint of the OTLP trace receiver. Should be in the form of ip:port or host:port. |
| trace.otlp.insecure | bool | `false` | Set to `true` to disable TLS. Set to false if TLS is in use by the OTLP trace receiver. |
| trace.otlp.samplingRate | string | `"1"` | Sampling rate between 0 and 1. 1 being 100% of traces are sent. |
| trace.type | string | `""` | Trace type to use. Valid options include `otlp`. |
| transform_agent.name | string | `""` | Transform Agent Image name to be used. Defaults to `ghcr.io/observiq/bindplane-transform-agent`. |
| transform_agent.replicas | int | `1` | Number of replicas to use for the transform agent. |
| transform_agent.tag | string | `""` | Transform Agent Image tag to use. Defaults to latest. |

