```
helm repo add jetstack/cert-manager https://charts.jetstack.io
helm repo update
helm template cert-manager jetstack/cert-manager \
  --version 1.6.0 \
  --namespace cert-manager \
  --values values.yaml \
  --output-dir base
```

```
helm repo add okteto https://charts.okteto.com
helm repo update
helm template cert-manager-webhook-civo okteto/cert-manager-webhook-civo \
  --namespace cert-manager \
  --output-dir base
```
