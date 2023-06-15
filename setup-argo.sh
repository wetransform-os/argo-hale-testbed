#!/bin/bash


# Argo
echo "Making sure Argo is installed in the cluster..."
kubectl create namespace argo --dry-run=client -o yaml | kubectl apply -f -
kubectl -n argo apply -f https://raw.githubusercontent.com/argoproj/argo-workflows/v3.0.10/manifests/quick-start-postgres.yaml
# create prerequisites for Argo access token - https://argoproj.github.io/argo-workflows/access-token/
kubectl -n argo create role argo-user --verb=list,update,create,get,watch,patch,delete --resource=workflows.argoproj.io,workflowtemplates.argoproj.io --resource=pods,pods/log,secret --dry-run=client -o yaml | kubectl apply -f -
kubectl -n argo create sa argo-user --dry-run=client -o yaml | kubectl apply -f -
kubectl -n argo create rolebinding argo-user --role=argo-user --serviceaccount=argo:argo-user --dry-run=client -o yaml | kubectl apply -f -
# in Kubernetes 1.24+ non-expiring tokens are no longer generated automatically for service accounts
# manually creating a secret also works for earlier versions though
cat <<EOL | kubectl -n argo apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: argo-user-token
  annotations:
    kubernetes.io/service-account.name: argo-user
type: kubernetes.io/service-account-token
EOL
# patch Argo to run w/o SSL
# https://argoproj.github.io/argo-workflows/tls/
kubectl patch deployment \
  argo-server \
  --namespace argo \
  --type='json' \
  -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/args", "value": [
  "server",
  "--namespaced",
  "--auth-mode",
  "server",
  "--auth-mode",
  "client",
  "--secure=false"
]},
  {"op": "replace", "path": "/spec/template/spec/containers/0/readinessProbe/httpGet/scheme", "value": "HTTP"}
]'

# wait for token to be populated
sleep 5s

# get token
SECRET=argo-user-token # $(kubectl -n argo get sa argo-user -o=jsonpath='{.secrets[0].name}')
ARGO_TOKEN="Bearer $(kubectl -n argo get secret $SECRET -o=jsonpath='{.data.token}' | base64 --decode)"
echo ""
echo "Access token for Argo is:"
echo $ARGO_TOKEN
echo ""


# store argo token
cat >env-argo.sh <<EOL
#!/bin/bash

export ARGO_SERVER='localhost:2746'
export ARGO_HTTP1=true
export ARGO_SECURE=false
export ARGO_BASE_HREF=
export ARGO_TOKEN="$ARGO_TOKEN"
export ARGO_NAMESPACE=argo

argo list
EOL
