#!/bin/bash

# Build, push and deploy nginx hosting test transformation projects

docker build -t localhost:5000/wetransform/static-projects:latest images/static-projects
docker push localhost:5000/wetransform/static-projects:latest

kubectl delete -f manifests/static-projects.yaml # force update
kubectl apply -f manifests/static-projects.yaml


# Build, push and deploy nginx hosting test source data

docker build -t localhost:5000/wetransform/static-sources:latest images/static-sources
docker push localhost:5000/wetransform/static-sources:latest

kubectl delete -f manifests/static-sources.yaml # force update
kubectl apply -f manifests/static-sources.yaml
