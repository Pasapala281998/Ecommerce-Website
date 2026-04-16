# Deploy E-Commerce App to Azure App Service and ACR
# Run this script after quota increase is approved

$resourceGroup = "ecommerce-rg"
$appServicePlan = "ecommerce-plan"
$webAppName = "ecommerce-app-$(Get-Random)"
$acrName = "ecommerceacr2025"
$acrLoginServer = "$acrName.azurecr.io"
$imageName = "ecommerce-app:latest"

Write-Host "=== Step 1: Create App Service Plan ===" -ForegroundColor Green
az appservice plan create --name $appServicePlan `
  --resource-group $resourceGroup `
  --sku B1

Write-Host "`n=== Step 2: Create Web App ===" -ForegroundColor Green
az webapp create --resource-group $resourceGroup `
  --plan $appServicePlan `
  --name $webAppName

Write-Host "`n=== Step 3: Deploy Application Files ===" -ForegroundColor Green
# Create app.zip if not exists
if (-not (Test-Path "app.zip")) {
    Compress-Archive -Path *.html, *.js, *.css, images, img, faked -DestinationPath app.zip -Force
}

az webapp deployment source config-zip --resource-group $resourceGroup `
  --name $webAppName `
  --src app.zip

Write-Host "`n=== Step 4: Get Web App URL ===" -ForegroundColor Green
$webAppUrl = az webapp show --resource-group $resourceGroup --name $webAppName --query defaultHostName -o tsv
Write-Host "Your app is now available at: https://$webAppUrl" -ForegroundColor Cyan

Write-Host "`n=== Step 5: Build Docker Image ===" -ForegroundColor Green
Write-Host "Building Docker image: $acrLoginServer/$imageName"
docker build -t "$acrLoginServer/$imageName" .

Write-Host "`n=== Step 6: Login to ACR ===" -ForegroundColor Green
az acr login --name $acrName

Write-Host "`n=== Step 7: Push to ACR ===" -ForegroundColor Green
docker push "$acrLoginServer/$imageName"

Write-Host "`n=== Deployment Complete! ===" -ForegroundColor Green
Write-Host "Web App URL: https://$webAppUrl"
Write-Host "ACR Image: $acrLoginServer/$imageName"
