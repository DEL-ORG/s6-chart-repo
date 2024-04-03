#!/bin/bash

kubectl create secret docker-registry ecr-revive \
  --docker-server=637423375996.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password="$(aws ecr get-login-password --region us-east-1)"


# NAMESPACE_NAME="revive" && \
# kubectl create namespace $NAMESPACE_NAME || true && \
# kubectl create secret docker-registry ecr-revive \
#   --docker-server=${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com \
#   --docker-username=AWS \
#   --docker-password=$(aws ecr get-login-password) \
#   --namespace=$NAMESPACE_NAME
