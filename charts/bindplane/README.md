# bindplane

![Version: 0.0.16](https://img.shields.io/badge/Version-0.0.16-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.8.0](https://img.shields.io/badge/AppVersion-1.8.0-informational?style=flat-square)

BindPlane OP is an open source observability pipeline.

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
| auth.ldap.tls.insecure | bool | `false` | Whether or not to skip verification of the ldap server's certificate. |
| auth.type | string | `"system"` | Backend to use for authentication. Available options include `system`, `ldap` (Enterprise), `active-directory` (Enterprise), and `google` (Enterprise). |
| autoscaling.enable | bool | `false` | "Whether or not autoscaling should be enabled. Requires an eventbus to be configured." |
| autoscaling.max | int | `10` | "Maximum number of pods when autoscaling is enabled." |
| autoscaling.min | int | `2` | "Minimum number of pods when autoscaling is enabled." |
| autoscaling.targetCPUUtilizationPercentage | int | `60` | "Autoscaling target CPU usage percentage." |
| autoscaling.targetMemoryUtilizationPercentage | int | `60` | "Autoscaling target Memory usage percentage." |
| backend.bbolt.volumeSize | string | `"10Gi"` | Persistent volume size. |
| backend.postgres.database | string | `""` | Database to use. |
| backend.postgres.host | string | `"localhost"` | Hostname or IP address of the Postgres server. |
| backend.postgres.maxConnections | int | `100` | Max number of connections to use when communicating with Postgres. |
| backend.postgres.password | string | `""` | Password for the username used to connect to Postgres. |
| backend.postgres.port | int | `5432` | TCP port used to connect to Postgres. |
| backend.postgres.sslmode | string | `"disable"` | SSL mode to use when connecting to Postgres over TLS. See the [postgres ssl documentation](https://jdbc.postgresql.org/documentation/ssl/) for valid options. |
| backend.postgres.username | string | `""` | Username to use when connecting to Postgres. |
| backend.type | string | `"bbolt"` | Backend to use for persistent storage. Available options are `bbolt`, and `postgres` (Enterprise). |
| config.password | string | `""` | Password to use. Overrides `config.secret`. |
| config.remote_url | string | `"ws://bindplane-op:3001"` | URI used by agents to communicate with BindPlane using OpAMP. |
| config.secret | string | `"bindplane"` | Name of the Kubernetes secret which contains the `username`, `password`, `secret_key`, and `sessions_secret` configuration options. |
| config.secret_key | string | `""` | Secret Key to use. Overrides `config.secret`. |
| config.server_url | string | `"http://bindplane-op:3001"` | URI used by clients to communicate with BindPlane. |
| config.sessions_secret | string | `""` | Sessions Secret to use. Overrides `config.secret`. |
| config.username | string | `""` | Username to use. Overrides `config.secret`. |
| email.sendgrid.token | string | `""` | The sendgrid API token to use when authenticating to Sendgrid. |
| email.type | string | `""` | The optional email backend type to use (Enterprise). Valid options include `sendgrid`. Requires an auth type other than `system`. |
| enterprise | bool | `false` | Whether or not enterprise edition is enabled. Enterprise users require a valid Enterprise subscription. |
| eventbus.pubsub.credentials.secret | string | `""` | Optional Kubernetes secret which contains Google Cloud JSON service account credentials. Not required when running within Google Cloud with the Pub/Sub scope enabled. |
| eventbus.pubsub.credentials.subPath | string | `""` | Sub path for the secret which contains the Google Cloud credential JSON |
| eventbus.pubsub.projectid | string | `""` |  |
| eventbus.pubsub.topic | string | `""` |  |
| eventbus.type | string | `""` |  |
| image.name | string | `""` | Image name to be used. Defaults to `ghcr.io/observiq/bindplane` and `ghcr.io/observiq/bindplane-ee` for Enterprise deployments. |
| image.tag | string | `""` | Image tag to use. Defaults to the version defined in the Chart's release. |
| ingress.class | string | `nil` | Ingress class to use when ingress is enabled. |
| ingress.enable | bool | `false` | Whether or not to enable ingress. |
| ingress.host | string | `nil` | Hostname to use when ingress is enabled. |
| multiAccount | bool | `false` | Whether or not multi account support is enabled (Enterprise). |
| resources.limits.memory | string | `"500Mi"` | Memory limit. |
| resources.requests.cpu | string | `"250m"` | CPU request. |
| resources.requests.memory | string | `"250Mi"` | Memory request. |
| trace.otlp.endpoint | string | `""` | "Endpoint of the OTLP trace receiver. Should be in the form of ip:port or host:port." |
| trace.otlp.insecure | bool | `false` | "Set to `true` to disable TLS. Set to false if TLS is in use by the OTLP trace receiver." |
| trace.type | string | `""` | Trace type to use. Valid options include `otlp`. |

