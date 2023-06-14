#!/bin/bash

# Build and push transformer image

docker build -t localhost:5000/wetransform/hale-transformer:latest images/hale-transformer
docker push localhost:5000/wetransform/hale-transformer:latest
