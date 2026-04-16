# Deploy ACR and AKS to Azure

This guide will help you create Azure Container Registry (ACR) and Azure Kubernetes Service (AKS) for the ecommerce website.

## Prerequisites

1. **Azure CLI** installed ([Download](https://aka.ms/cli))
2. **kubectl** installed ([Download](https://kubernetes.io/docs/tasks/tools/))
3. Azure subscription (already have: `2946c9da-46b7-4167-88a5-7327db6cedca`)
4. Azure DevOps project with pipeline configured

## Step 1: Create Resource Group

```powershell
# Define variables
$subscriptionId = "2946c9da-46b7-4167-88a5-7327db6cedca"
$resourceGroupName = "ecommerce-rg"
$location = "eastus"

# Login to Azure
az login

# Set subscription
az account set --subscription $subscriptionId

# Create resource group
az group create `
  --name $resourceGroupName `
  --location $location
```

## Step 2: Deploy Infrastructure with Bicep

```powershell
# Deploy ACR and AKS using Bicep
az deployment group create `
  --name "aks-acr-deployment" `
  --resource-group $resourceGroupName `
  --template-file "./infra/main.bicep" `
  --parameters "./infra/parameters.bicepparam"

# Save the outputs (you'll need these for the pipeline)
$deployment = az deployment group show `
  --name "aks-acr-deployment" `
  --resource-group $resourceGroupName `
  --query properties.outputs -o json | ConvertFrom-Json

Write-Host "ACR Login Server: $($deployment.acrLoginServer.value)"
Write-Host "AKS Cluster Name: $($deployment.aksClusterName.value)"
```

## Step 3: Configure kubectl Access

```powershell
# Get AKS credentials
az aks get-credentials `
  --resource-group $resourceGroupName `
  --name "ecommerce-aks-prod" `
  --admin

# Verify connection
kubectl get nodes
kubectl get namespaces
```

## Step 4: Create ACR Connection in Azure DevOps

1. Go to your Azure DevOps project
2. Navigate to **Project Settings → Service Connections**
3. Click **New Service Connection → Docker Registry**
4. Select **Azure Container Registry**
5. Choose your subscription and ACR: `ecommerceacr<random>`
6. Name it: **ACRConnection**
7. Click **Save**

## Step 5: Create AKS Connection in Azure DevOps

1. In **Project Settings → Service Connections**
2. Click **New Service Connection → Kubernetes**
3. Select **Azure Subscription**
4. Choose your subscription
5. Resource Group: `ecommerce-rg`
6. AKS cluster: `ecommerce-aks-prod`
7. Name it: **ecommerce-aks**
8. Click **Save**

## Step 6: Create SonarQube Connection (Optional)

1. In **Project Settings → Service Connections**
2. Click **New Service Connection → Generic**
3. Enter your SonarQube server details
4. Name it: **SonarQube**
5. Click **Save**

## Step 7: Run the Pipeline

1. Go to **Pipelines**
2. Select the pipeline
3. Click **Run Pipeline**
4. The pipeline will:
   - Run SonarQube analysis
   - Build Docker image
   - Push to ACR
   - Deploy to AKS

## Verify Deployment

```powershell
# Check AKS deployment
kubectl get deployments
kubectl get services
kubectl get pods

# Check ACR images
az acr repository list --name ecommerceacr<random> --output table

# View application
# Get the LoadBalancer IP
kubectl get service ecommerce-app
# Visit: http://<EXTERNAL-IP>
```

## Clean Up (if needed)

```powershell
# Delete resource group (this will delete ACR and AKS)
az group delete --name $resourceGroupName --yes --no-wait
```

## Troubleshooting

### ACR Connection Fails
- Check Docker Registry service connection in DevOps
- Verify ACR name is correct
- Ensure you have permission to the subscription

### AKS Deployment Fails
- Check kubectl connection: `kubectl cluster-info`
- Verify service connection credentials
- Check YAML manifests: `k8s-deployment.yaml`, `k8s-service.yaml`

### Image Pull Fails
- Verify ACR login secret in AKS
- Check image name format in deployment

## Next Steps

1. Update `k8s-deployment.yaml` with your image references
2. Configure health checks and resource limits
3. Set up monitoring and logging
4. Configure autoscaling
