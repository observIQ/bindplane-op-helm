# Google Kubernetes Engine

This example deploys BindPlane to GKE, sized to support 20,000 agents.

## Create Namespace

Create the `bindplane` namespace.

```bash
kubectl create namespace bindplane
```

## Create Secret

Create the `bindplane` secret in the `bindplane` namespace.
See the [secret](/README.md#create-secret) documentation for
more information.

```bash
kubectl -n bindplane create secret generic bindplane \
  --from-literal=username=<username> \
  --from-literal=password=<password> \
  --from-literal=secret_key=<secret key> \
  --from-literal=sessions_secret=<session secret> \
  --from-literal=license=<license>
```

Example:

```bash
kubectl -n bindplane create secret generic bindplane \
  --from-literal=username=my-username \
  --from-literal=password=my-secure-password \
  --from-literal=secret_key=353753ca-ae48-40f9-9588-28cf86430910 \
  --from-literal=sessions_secret=d9425db6-c4ee-4769-9c1f-a66987679e90 \
  --from-literal=license=mylicense-key
```

## Configure

Edit the `values.yaml` file in this directory.

### Ingress

Remove the `ingress` block if you do not want to use an ingress class
to provide access to BindPlane. This example uses Ingress NGINX with
Cert Manager.

```yaml
ingress:
  enable: true
  host: bindplane.data-metric.com
  class: nginx
  tls:
    enable: true
    secret: bindplane-tls
  annotations:
    cert-manager.io/issuer: letsencrypt
```

If removing ingress, remove the `config.server_url` option. If using
ingress, update `config.server_url` to match your ingress hostname.

```yaml
config:
  server_url: https://bindplane.data-metric.com
```

### Pub/Sub

Update the Pub/Sub `projectid` and `topic`.

```yaml
eventbus:
  type: 'pubsub'
  pubsub:
    projectid: 'my-project'
    topic: 'bindplane'
```

Make sure your GKE node pool's have the [Pub/Sub scope](https://developers.google.com/identity/protocols/oauth2/scopes#pubsub) enabled.

### Postgres

Update the Postgres configuration's `host`, `database`, `username` and `password` options to reflect your environment.

```yaml
backend:
  type: postgres
  postgres:
    host: '34.23.43.29'
    port: 5432
    database: 'bindplane'
    username: 'your-username'
    password: 'your-secure-password'
    maxConnections: 10
```

## Deploy

```bash
helm repo update

helm upgrade \
    --values="values.yaml" \
    --namespace=bindplane \
    --create-namespace \
    --install \
    bindplane \
    bindplane/bindplane
```

Once deployed, the `bindplane` namespace will look like this:

```
NAME                                         READY   STATUS  
bindplane-58968545f8-6n6pm                   1/1     Running  
bindplane-58968545f8-79rt4                   1/1     Running  
bindplane-58968545f8-7wtbh                   1/1     Running   
bindplane-58968545f8-987pb                   1/1     Running   
bindplane-58968545f8-cxpkq                   1/1     Running   
bindplane-58968545f8-whg6v                   1/1     Running   
bindplane-58968545f8-z5wm7                   1/1     Running   
bindplane-prometheus-0                       1/1     Running   
bindplane-transform-agent-675d8f5865-8rzrn   1/1     Running   
bindplane-transform-agent-675d8f5865-pgvh2   1/1     Running   
```

If using ingress, the ingress resource will look like this:

```
NAME        CLASS    HOSTS                       ADDRESS         PORTS     AGE
bindplane   <none>   bindplane.data-metric.com   34.23.141.224   80, 443   74m
```

If using ingress with TLS, a certificate and secret resource will be present in the namespace.

```bash
$ kubectl -n bindplane get certificate
NAME            READY   SECRET          AGE
bindplane-tls   True    bindplane-tls   72m
```
```bash
$ kubectl -n bindplane get secret bindplane-tls
NAME            TYPE                DATA   AGE
bindplane-tls   kubernetes.io/tls   2      70m
```

