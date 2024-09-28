#!/bin/bash
# Cleanup All Resources
# export POSTGRES_HOSTPATH="/Users/saurav/Tech/Kubernetes/pv_pvc/data/postgres"
# export MINIO_HOSTPATH="/Users/saurav/Tech/Kubernetes/pv_pvc/data/minio"
# export REGISTRY_HOSTPATH="/Users/saurav/Tech/Kubernetes/pv_pvc/data/registry"


kubectl delete -f mlflow/mlflow-inference-ing.yaml
kubectl delete -f mlflow/mlflow-inference-svc.yaml
kubectl delete -f mlflow/mlflow-inference-deploy.yaml

rm -rf mlflow-testing

kubectl delete -f mlflow/mlflow-tracking-ing.yaml
kubectl delete -f mlflow/mlflow-tracking-svc.yaml
kubectl delete -f mlflow/mlflow-tracking-deploy.yaml

kubectl delete -f mlflow/mlflow-secret.yaml
kubectl delete secret mlflow-inference-tls --namespace mlops
kubectl delete secret mlflow-tracking-tls --namespace mlops

kubectl delete -f registry/registry-ing.yaml
kubectl delete -f registry/registry-svc.yaml
kubectl delete -f registry/registry-deploy.yaml
kubectl delete -f registry/registry-secret.yaml
kubectl delete secret registry-tls --namespace mlops
kubectl delete -f registry/registry-sc-pv-pvc.yaml

kubectl delete -f minio/minio-ui-ing.yaml
kubectl delete -f minio/minio-ing.yaml
kubectl delete secret minio-ui-tls --namespace mlops
kubectl delete secret minio-tls --namespace mlops
kubectl delete -f minio/minio-svc.yaml
kubectl delete -f minio/minio-deploy.yaml
kubectl delete -f minio/minio-secret.yaml
kubectl delete -f minio/minio-sc-pv-pvc.yaml

kubectl delete -f postgres/postgres-svc.yaml
kubectl delete -f postgres/postgres-deploy.yaml
kubectl delete -f postgres/postgres-secret.yaml
kubectl delete -f postgres/postgres-sc-pv-pvc.yaml
kubectl delete -f namespace.yaml

rm -rf $REGISTRY_HOSTPATH
rm -rf $MINIO_HOSTPATH
rm -rf $POSTGRES_HOSTPATH

sed -i '' "s|    path: $POSTGRES_HOSTPATH|    path: POSTGRES_HOSTPATH|g" postgres/postgres-sc-pv-pvc.yaml
sed -i '' "s|    path: $MINIO_HOSTPATH|    path: MINIO_HOSTPATH|g" minio/minio-sc-pv-pvc.yaml
sed -i '' "s|    path: $REGISTRY_HOSTPATH|    path: REGISTRY_HOSTPATH|g" registry/registry-sc-pv-pvc.yaml
