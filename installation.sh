#!/bin/bash
## Tracking

# Host path on MacOS
# export POSTGRES_HOSTPATH="/Users/saurav/Tech/Kubernetes/pv_pvc/data/postgres"
# export MINIO_HOSTPATH="/Users/saurav/Tech/Kubernetes/pv_pvc/data/minio"
# export REGISTRY_HOSTPATH="/Users/saurav/Tech/Kubernetes/pv_pvc/data/registry"


sed -i '' "s|    path: POSTGRES_HOSTPATH|    path: $POSTGRES_HOSTPATH|g" postgres/postgres-sc-pv-pvc.yaml
sed -i '' "s|    path: MINIO_HOSTPATH|    path: $MINIO_HOSTPATH|g" minio/minio-sc-pv-pvc.yaml
sed -i '' "s|    path: REGISTRY_HOSTPATH|    path: $REGISTRY_HOSTPATH|g" registry/registry-sc-pv-pvc.yaml


# POSTGRESQL
kubectl apply -f namespace.yaml
kubectl apply -f postgres/postgres-sc-pv-pvc.yaml
kubectl apply -f postgres/postgres-secret.yaml
kubectl apply -f postgres/postgres-deploy.yaml
kubectl apply -f postgres/postgres-svc.yaml


# MINIO
kubectl apply -f minio/minio-sc-pv-pvc.yaml
kubectl apply -f minio/minio-secret.yaml
kubectl apply -f minio/minio-deploy.yaml
kubectl apply -f minio/minio-svc.yaml
kubectl create secret tls minio-tls --namespace mlops --cert=minio/selfsigned.crt --key=minio/selfsigned.key
kubectl create secret tls minio-ui-tls --namespace mlops --cert=minio/selfsigned-ui.crt --key=minio/selfsigned-ui.key
kubectl apply -f minio/minio-ing.yaml
kubectl apply -f minio/minio-ui-ing.yaml


# Create MinIO Bucket
until curl -k --output /dev/null --silent --head --fail https://minio.local/minio/health/live; do
    printf '.'
    sleep 5
done
mc alias set myminio https://minio.local admin Password1234 --insecure
mc ls myminio --insecure
mc mb myminio/mlflow-artifacts --insecure
mc ls myminio/mlflow-artifacts --insecure


# REGISTRY
kubectl apply -f registry/registry-sc-pv-pvc.yaml
kubectl create secret tls registry-tls --namespace mlops --cert=registry/selfsigned.crt --key=registry/selfsigned.key
kubectl apply -f registry/registry-secret.yaml
kubectl apply -f registry/registry-deploy.yaml
kubectl apply -f registry/registry-svc.yaml
kubectl apply -f registry/registry-ing.yaml

until curl -k --output /dev/null --silent --head --fail https://registry.local; do
    printf '.'
    sleep 5
done
docker login registry.local -u admin -p Passw0rd1234


# MLFLOW
kubectl create secret tls mlflow-tracking-tls --namespace mlops --cert=mlflow/selfsigned.crt --key=mlflow/selfsigned.key
kubectl create secret tls mlflow-inference-tls --namespace mlops --cert=mlflow/selfsigned-inference.crt --key=mlflow/selfsigned-inference.key
kubectl apply -f mlflow/mlflow-secret.yaml

# Build Custom Image
docker build -t registry.local/mlflow:v1 -f mlflow/Dockerfile .
docker push registry.local/mlflow:v1

kubectl apply -f mlflow/mlflow-tracking-deploy.yaml
kubectl apply -f mlflow/mlflow-tracking-svc.yaml
kubectl apply -f mlflow/mlflow-tracking-ing.yaml



# Build Model
until curl -k --output /dev/null --silent --head --fail https://mlflow-tracking.local; do
    printf '.'
    sleep 5
done

export MLFLOW_TRACKING_URI=https://mlflow-tracking.local
export MLFLOW_TRACKING_INSECURE_TLS=true
export MLFLOW_S3_ENDPOINT_URL=https://minio.local
export MLFLOW_S3_IGNORE_TLS=true
export MLFLOW_ARTIFACTS_DESTINATION=s3://mlflow-artifacts
export AWS_ACCESS_KEY_ID=admin
export AWS_SECRET_ACCESS_KEY=Password1234

mkdir mlflow-testing
cd mlflow-testing

python3 -m venv env
source env/bin/activate
pip3 install --upgrade pip
pip3 install mlflow
pip3 install boto3
pip3 install scikit-learn

git clone https://github.com/mlflow/mlflow
python3 mlflow/examples/sklearn_elasticnet_wine/train.py
deactivate
