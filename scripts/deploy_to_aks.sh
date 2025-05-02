#!/bin/bash
set -e

# ===== NEW CONFIG SECTION =====
# Azure Resources
RESOURCE_GROUP="crime-analysis-rg"
ACR_NAME="crimeanalysisacr"  
AKS_CLUSTER="crime-analysis-aks"
KEY_VAULT_NAME="crime-analysis-kv"

# App Settings
APP_NAME="crime-analysis"
TAG="latest"
DOCKERFILE_PATH="infra/docker/Dockerfile"  # ← Updated path
K8S_MANIFEST_DIR="infra/docker/k8s"       # ← New manifest directory

# ===== NEW AUTHENTICATION =====
az login --service-principal \
  -u "$ARM_CLIENT_ID" \
  -p "$ARM_CLIENT_SECRET" \
  --tenant "$ARM_TENANT_ID"

# ===== NEW ACR SETUP =====
if ! az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP &>/dev/null; then
  az acr create \
    --resource-group $RESOURCE_GROUP \
    --name $ACR_NAME \
    --sku Basic \
    --admin-enabled true
fi
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)

# ===== NEW IMAGE BUILD/PUSH =====
docker build -t $ACR_LOGIN_SERVER/$APP_NAME:$TAG -f $DOCKERFILE_PATH .
az acr login --name $ACR_NAME
docker push $ACR_LOGIN_SERVER/$APP_NAME:$TAG

# ===== NEW CSI DRIVER INSTALL =====
helm install csi csi-secrets-store-provider-azure/csi-secrets-store-provider-azure \
  --namespace kube-system \
  --version 1.4.0

# ===== UPDATED DEPLOYMENT =====
sed -i "s|image:.*|image: $ACR_LOGIN_SERVER/$APP_NAME:$TAG|g" $K8S_MANIFEST_DIR/deployment.yaml
kubectl apply -f $K8S_MANIFEST_DIR/.
