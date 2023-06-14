Hale transformation testbed with Argo Workflows
===============================================

Requirements
------------

**TODO**


Setup
-----

**TODO**


### Minikube

```
minikube addons enable registry
```

```
kubectl port-forward --namespace kube-system service/registry 5000:80
```

```
curl http://localhost:5000/v2/_catalog
```



Usage
-----

### Access to Argo

Local port forwarding from Argo service:

```
kubectl -n argo  port-forward service/argo-server 2746:2746
```

Then the Argo Server UI can be accessed at <http://localhost:2746>

Configure environment for Argo CLI:

```
source ./env-argo.sh
```

Submit a workflow:

```
argo submit --watch workflows/hello-world.yaml
```


Transformation workflows
------------------------

**TODO**
