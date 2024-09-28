#!/bin/bash
## Inference

# export EXPERIMENT_ID=0
# export RUN_ID=b610146213114c4f901a3d4ca6a4ac0e

cd mlflow-testing
source env/bin/activate
export MLFLOW_TRACKING_URI=https://mlflow-tracking.local
export MLFLOW_TRACKING_INSECURE_TLS=true
export MLFLOW_S3_ENDPOINT_URL=https://minio.local
export MLFLOW_S3_IGNORE_TLS=true
export MLFLOW_ARTIFACTS_DESTINATION=s3://mlflow-artifacts
export AWS_ACCESS_KEY_ID=admin
export AWS_SECRET_ACCESS_KEY=Password1234
export DOCKER_DEFAULT_PLATFORM=linux/arm64

mlflow models build-docker -m $MLFLOW_ARTIFACTS_DESTINATION/$EXPERIMENT_ID/$RUN_ID/artifacts/model -n registry.local/mlflow-wine-classifier:v1
deactivate

docker login registry.local -u admin -p Passw0rd1234
docker push registry.local/mlflow-wine-classifier:v1

cd ..
kubectl apply -f mlflow/mlflow-inference-deploy.yaml
kubectl apply -f mlflow/mlflow-inference-svc.yaml
kubectl apply -f mlflow/mlflow-inference-ing.yaml

until curl -k --output /dev/null --silent --head --fail https://mlflow-inference.local/health; do
    printf '.'
    sleep 5
done

curl -k -H "Content-Type: application/json" https://mlflow-inference.local/invocations -d @./test-input.json
