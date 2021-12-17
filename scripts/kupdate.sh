#!/bin/bash
# CB Specific!

set -e;

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <environment ID> <commit ID>"
  exit 1
fi

ENV_ID=$1
COMMIT=$2

kubectl config use-context dev${ENV_ID}
kubectl cluster-info

for file in $(ls src/*tmp${ENV_ID}*); do
    echo "Updating commit number in $file"
    sed -i -E "s/subscriptions:dev-${ENV_ID}_(.*)/subscriptions:dev-${ENV_ID}_${COMMIT}/" $file
done

for deployment in $(kubectl get deployments | grep subscription | cut -d' ' -f1); do
    echo "delete deployments $deployment<"
    kubectl delete deployments $deployment
done

for file in $(ls src/*tmp${ENV_ID}*); do
    echo "Processing $file"
    kubectl apply -f $file
done

