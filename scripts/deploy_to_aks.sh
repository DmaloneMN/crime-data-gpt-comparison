#!/bin/bash
# Authenticate to Azure
az login --service-principal \
  -u $ARM_CLIENT_ID \
  -p $ARM_CLIENT_SECRET \
  --tenant $ARM_TENANT_ID

# Deploy AKS cluster
cd infra/aks
terraform init
terraform apply -auto-approve

# Configure kubectl
az aks get-credentials \
  --resource-group $(terraform output -raw resource_group_name) \
  --name $(terraform output -raw cluster_name)

# Deploy to AKS
cd ../docker/k8s
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
