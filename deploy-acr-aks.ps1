# PowerShell script to deploy ACR and AKS infrastructure
# Usage: ./deploy-acr-aks.ps1

param (
    [string]$SubscriptionId = "2946c9da-46b7-4167-88a5-7327db6cedca",
    [string]$ResourceGroupName = "ecommerce-rg",
    [string]$Location = "eastus"
)

Write-Host "Starting ACR and AKS Deployment" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Step 1: Login and set subscription
Write-Host "`n[1/6] Logging into Azure..." -ForegroundColor Yellow
az login

Write-Host "[+] Setting subscription to $SubscriptionId" -ForegroundColor Green
az account set --subscription $SubscriptionId

# Step 2: Create resource group
Write-Host "`n[2/6] Creating Resource Group..." -ForegroundColor Yellow
az group create `
    --name $ResourceGroupName `
    --location $Location

Write-Host "[+] Resource Group '$ResourceGroupName' created/verified in $Location" -ForegroundColor Green

# Step 3: Deploy infrastructure with Bicep
Write-Host "`n[3/6] Deploying ACR and AKS Infrastructure (this may take 5-10 minutes)..." -ForegroundColor Yellow
az deployment group create `
    --name "ecommerce-infrastructure" `
    --resource-group $ResourceGroupName `
    --template-file "./infra/main.bicep" `
    --parameters "./infra/parameters.bicepparam" `
    --output table

Write-Host "[+] Infrastructure deployment completed!" -ForegroundColor Green

# Step 4: Get deployment outputs
Write-Host "`n[4/6] Retrieving deployment information..." -ForegroundColor Yellow
$deployment = az deployment group show `
    --name "ecommerce-infrastructure" `
    --resource-group $ResourceGroupName `
    --query properties.outputs -o json | ConvertFrom-Json

$acrName = $deployment.acrName.value
$acrLoginServer = $deployment.acrLoginServer.value
$aksClusterName = $deployment.aksClusterName.value

Write-Host "`n[+] Deployment Details:" -ForegroundColor Green
Write-Host "   Resource Group: $ResourceGroupName"
Write-Host "   ACR Name: $acrName"
Write-Host "   ACR Login Server: $acrLoginServer"
Write-Host "   AKS Cluster: $aksClusterName"

# Step 5: Configure kubectl access
Write-Host "`n[5/6] Configuring kubectl access..." -ForegroundColor Yellow
az aks get-credentials `
    --resource-group $ResourceGroupName `
    --name $aksClusterName `
    --admin

# Verify connection
Write-Host "`n[6/6] Verifying Kubernetes cluster connection..." -ForegroundColor Yellow
kubectl cluster-info
kubectl get nodes

Write-Host "`n[+] Kubernetes cluster is ready!" -ForegroundColor Green

# Display next steps
Write-Host "`n[NEXT STEPS]" -ForegroundColor Cyan
Write-Host "1. Configure ACR Service Connection in Azure DevOps"
Write-Host "2. Configure AKS Service Connection in Azure DevOps"
Write-Host "3. Configure SonarQube Service Connection (optional)"
Write-Host "4. Update k8s-deployment.yaml with image: $acrLoginServer/ecommerce-app:latest"
Write-Host "5. Run the Azure Pipeline"
Write-Host "`nFor detailed instructions, see: SETUP_ACR_AKS.md" -ForegroundColor Cyan

Write-Host "`n[SUCCESS] ACR and AKS deployment complete!" -ForegroundColor Green
