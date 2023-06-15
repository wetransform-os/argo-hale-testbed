Argo Workflows for transformation with hale-cli
===============================================

Transformation workflows
------------------------

This repository contains a number of example workflows for running a transformation with hale-cli in Argo Workflows.
Out of the box these workflows are intended to be run with the test setup described here, but they can be easily adapted to run in another environment.

**Note:** All workflows defined here assume XML/GML files as sources for the transformations (in most cases expected within a Zip archive).
Other kinds of sources may require additional configuration related to loading the data for the transformation.

### Transformation of GML file using hale-cli

This workflow is defined in [workflows/transform-orgcli-example.yaml](./workflows/transform-orgcli-example.yaml).

The workflow specifies the URL to a GML file and to a hale project archive.
The hale-cli image is used to transform the source file.
The transformation result and related files are stored as workflow outputs in the artifact repository.

To run with argo CLI in the test setup:

```
argo submit --watch workflows/transform-orgcli-example.yaml
```

### Transformation of Zip with GML file using transformer image

This workflow is defined in [workflows/transform-transformer-example.yaml](./workflows/transform-transformer-example.yaml).

The workflow specifies the URL to a Zip file, that contains the GML data to transform, and to a hale project archive.
The transformer image defined in [images/hale-transformer](./images/hale-transformer) is used to transform the source file.
It expects the source file always to be a Zip archive that is extracted and all `.gml` files used as source for the transformation.
The transformation result and related files are stored as workflow outputs in the artifact repository.

To run with argo CLI in the test setup:

```
argo submit --watch workflows/transform-transformer-example.yaml
```

### Transformation of Zip with GML file using transformer workflow template

This workflow is similar to the above, but a [workflow template](./workflows/transformer-template/template.yaml) is used so that the [actual workflow](./workflows/transformer-template/workflow-example.yaml) only references the template and provides the required parameters.

To run with argo CLI in the test setup:

```
argo template create workflows/transformer-template/template.yaml
argo submit --watch workflows/transformer-template/workflow-example.yaml
```

To run with `kubectl` in the test setup:

```
kubectl -n argo apply -f workflows/transformer-template/template.yaml
kubectl -n argo create -f workflows/transformer-template/workflow-example.yaml
```


Requirements for running workflows
----------------------------------

Running the workflows requires at least:

- An installation of Argo Workflows (Version 3.4+ recommended)

The workflows as they are defined in the respository assume Argo is configured with a default artifact repository.
Artifacts in that case can be accessed via the Argo server API and UI or directly via the artifact repository.
But the workflows can also be easily adapted to store artifacts in an explicitly configured store and there in a specific location.
Here is an example of a configuration for one output artifact to be stored in S3:

```
artifacts:
  - name: my-artifact
    path: /path/to/output
    s3:
      bucket: my-s3-bucket
      endpoint: s3.amazonaws.com
      accessKeySecret:
        name: s3-access-key-secret
        key: accessKey
      secretKeySecret:
        name: s3-secret-key-secret
        key: secretKey
      key: my-folder/my-artifact.tar.gz
```

To submit the workflows there are different possibilities:

- Use the `argo` CLI (e.g. `argo submit`)
- Use the Kubernetes API (e.g. via `kubectl`)
- Use the Argo serve API

### Running outside of the test setup

The workflows defined here are intended to be use with the test setup described here.
With some small changes they can be used in other environments.

In the workflows transformation projects and source files used by default are part of the test setup.
For any use outside the test setup you need to provide the URLs to the source files and transformation projects you want to use.

Workflows that use the custom transformer image in [images/hale-transformer](./images/hale-transformer) have additional requirements:

- The image needs to be built and pushed to a registry
- The references to the image in the workflows needs to be adapted to use that image (by default they use the local registry of the test setup)


Test setup
----------

The test setup is intended to be run on minikube.
The setup was tested with a Kubernetes cluster of version 1.22, but should also work at least with versions up to 1.24.
Main factor here is the compatibility with the provided setup for Argo workflows (where version 3.0 is used that by default requires Docker).

To use a specific Kubernetes cluster version with minikube please have a look at the documentation [here](https://minikube.sigs.k8s.io/docs/handbook/config/#selecting-a-kubernetes-version).

Required tools:

- minikube
- kubectl
- bash

Recommended:

- argo CLI


### Minikube

Once you installed minikube you need to start a cluster with the `minikube start` command. For example:

```
minikube start --kubernetes-version=v1.22.2
```

For our custom images we need a registry. This can be provided by the `registry` addon for minikube. To enable it run the following command:

```
minikube addons enable registry
```

You also need to add a port forwarding to be able to access the registry locally:

```
kubectl port-forward --namespace kube-system service/registry 5000:80
```

If you are using macOS or Windows, additional configuration may be required. Please see the documentation [here](https://minikube.sigs.k8s.io/docs/handbook/registry/#enabling-insecure-registries).

To test acessing the local registry you can use this command:

```
curl http://localhost:5000/v2/_catalog
```

### Set up test resources

The workflows use source data and transformation projects for testing that need to be served via HTTP.
To facilitate that there are two nginx-based images that serve these files statically.

Use the `setup-resources.sh` script to build the images, push them to the local registry and deploy them.

### Build transformer image

Some workflows use the custom transformer image that extends the hale-cli image with a wrapper script.
For the image to be available and up-to-date it needs to be built and pushed to the local registry:

```
./build-transformer.sh
```

### Install Argo

Use the `setup-argo.sh` script to install Argo 3.0 into the cluster.
It uses `kubectl` to create the resources and a token for authentication.

The script creates a local file `env-argo.sh` that includes the generated token.

It may take some time for the token to be populated, even though there is some delay, you may need to run the script twice (just check the content of `env-argo.sh` if a token is included).

#### Access Argo

After Argo is installed you should run a local port forwarding to the Argo service:

```
kubectl -n argo  port-forward service/argo-server 2746:2746
```

Then the Argo Server UI can be accessed at <http://localhost:2746>

If you want to use argo CLI, you can configure you shell to talk to the right Argo server like this:

```
source ./env-argo.sh
```

For testing you can submit a workflow:

```
argo submit --watch workflows/hello-world.yaml
```
