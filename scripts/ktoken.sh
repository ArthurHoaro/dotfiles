#!/bin/bash

set -e

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <environment: e.g. staging>"
  exit 1
fi

export KUBE_ENVIRONMENT=$1

yq --version > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
  echo "This script requires yq tool: https://github.com/mikefarah/yq"
  exit 2
fi

jq --version > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
  echo "This script requires jq tool: https://github.com/stedolan/jq"
  exit 3
fi

export KUBE_TOKEN=$(aws --profile cobrowser eks get-token --cluster ${KUBE_ENVIRONMENT}-eks | jq -r '.status.token')
if [[ $? -ne 0 || -z $KUBE_TOKEN ]]; then
  echo "Failed to get EKS token"
  exit 4
fi

cp ~/.kube/config ~/.kube/config.$(date "+%Y.%m.%d-%H.%M.%S")

export KUBE_USER=${KUBE_ENVIRONMENT}-developers

yq e -i '(.users[] | select(.name==strenv(KUBE_USER)).user.token) |= strenv(KUBE_TOKEN)' ~/.kube/config
