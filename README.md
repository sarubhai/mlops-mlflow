# MLOps with MLflow on Kubernetes

This repository contains the source code for an MLOps demo using **MLflow** on a **Kubernetes** cluster.

For a detailed guide, follow the article: [Setup MLflow on Kubernetes](https://appdev24.com/pages/63/setup-mlflow-on-kubernetes)

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Setup Instructions](#setup-instructions)
3. [Running Model Inference](#running-model-inference)
4. [Cleanup](#cleanup)

## Prerequisites
Ensure the following tools are installed on your local machine:

- [Docker](https://www.docker.com/)
- [Kubernetes](https://kubernetes.io/) (Docker Desktop Kubernetes is sufficient)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [mc (MinIO Client)](https://min.io/docs/minio/linux/reference/minio-mc.html) (Install via Homebrew: `brew install minio/stable/mc`)

## Setup Instructions

### Step 1: DNS Configuration
Add the following DNS entries to your `/etc/hosts` file:

```
127.0.0.1	registry.local
127.0.0.1	minio.local
127.0.0.1	minio-ui.local
127.0.0.1	mlflow-tracking.local
127.0.0.1	mlflow-inference.local
```

### Step 2: Clone the Repository

Clone this repository to your local machine:
```
git clone https://github.com/sarubhai/mlops-mlflow.git
cd mlops-mlflow
```

### Step 3: Host Path Directories
Create the required host path directories for persistent storage. You can follow the detailed instructions in this article: [Setup Kubernetes Persistent Volumes on Docker Desktop](https://appdev24.com/pages/58/setup-kubernetes-persistent-volumes-on-docker-desktop).

### Step 4: Set Environment Variables
Update the following environment variables with your local paths:
```
# Host path on MacOS
export POSTGRES_HOSTPATH="/Users/your-username/Tech/Kubernetes/pv_pvc/data/postgres"
export MINIO_HOSTPATH="/Users/your-username/Tech/Kubernetes/pv_pvc/data/minio"
export REGISTRY_HOSTPATH="/Users/your-username/Tech/Kubernetes/pv_pvc/data/registry"
```

### Step 5: Deploy Resources
Run the deployment script to start the services:
```
./installation.sh
```

Once the setup is complete, you can access the MLflow tracking UI at:

[https://mlflow-tracking.local](https://mlflow-tracking.local)


## Running Model Inference
### Step 1: Experiment Run
Access the MLflow Tracking UI and note the Experiment ID and Run ID for the run you want to test. Set the environment variables accordingly:
```
export EXPERIMENT_ID=0
export RUN_ID=b610146213114c4f901a3d4ca6a4ac0e
```

### Step 2: Test Model Inference
Run the model inference test script:
```
./testing.sh
```

## Cleanup
To clean up resources and reset the environment:

### Step 1: Set Environment Variables
Ensure the environment variables are correctly set:
```
export POSTGRES_HOSTPATH="/Users/saurav/Tech/Kubernetes/pv_pvc/data/postgres"
export MINIO_HOSTPATH="/Users/saurav/Tech/Kubernetes/pv_pvc/data/minio"
export REGISTRY_HOSTPATH="/Users/saurav/Tech/Kubernetes/pv_pvc/data/registry"
```

### Step 2: Run Cleanup Script
Run the cleanup script to remove all resources:
```
./cleanup.sh
```
