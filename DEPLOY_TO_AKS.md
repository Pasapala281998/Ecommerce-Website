# Deploy to Azure Kubernetes Service (AKS)

## Prerequisites
You need to resolve the quota issue first. Follow these steps:

### Step 1: Request Azure Quota Increase
1. Go to https://portal.azure.com
2. Search for **"Quotas"** 
3. Select **"Compute"** from the left menu
4. Search for **"Standard D Family vCPUs"** or **"Standard DCds_v5 Family vCPUs"**
5. Click the quota name
6. Click **"Request quota increase"**
7. Set new limit to at least **4 (for 1 node with D4 size)**
8. Submit and wait for approval (usually 24 hours)

### Step 2: Create AKS Cluster

Once quota is approved, run:

```bash
az aks create \
  --resource-group ecommerce-rg \
  --name ecommerce-aks \
  --node-count 1 \
  --vm-set-type VirtualMachineScaleSets \
  --load-balancer-sku standard \
  --attach-acr ecommerceacr2025 \
  --generate-ssh-keys
```

### Step 3: Get Credentials

```bash
az aks get-credentials --resource-group ecommerce-rg --name ecommerce-aks
```

### Step 4: Deploy Application

```bash
# Navigate to the project directory
cd d:\Ecommerce-Website

# Create the namespaceand deploy secret for ACR
kubectl create namespace ecommerce

# Create ACR secret
kubectl create secret docker-registry acr-secret \
  --docker-server=ecommerceacr2025.azurecr.io \
  --docker-username=ecommerceacr2025 \
  --docker-password=GLHj8295jwvBYCErzYSazjm2Grmr8mUzXgCwDBjryVbirTYsYTQbJQQJ99CDACYeBjFEqg7NAAACAZCRB5mM \
  --docker-email=pasapalamahesh2@gmail.com

# Deploy application
kubectl apply -f k8s-deployment.yaml
kubectl apply -f k8s-service.yaml
```

### Step 5: Access Your Application

```bash
# Get the LoadBalancer IP (wait 1-2 minutes for it to be assigned)
kubectl get svc ecommerce-app-service

# Application will be available at: http://<EXTERNAL-IP>
```

### Step 6: Monitor Deployment

```bash
# Check deployment status
kubectl get deployments
kubectl get pods
kubectl get svc

# View pod logs
kubectl logs -l app=ecommerce-app

# Describe deployment for troubleshooting
kubectl describe deployment ecommerce-app
```

## Cleanup (Delete Everything)

```bash
# Delete the application
kubectl delete -f k8s-deployment.yaml
kubectl delete -f k8s-service.yaml

# Delete AKS cluster
az aks delete --resource-group ecommerce-rg --name ecommerce-aks

# Delete resource group
az group delete --name ecommerce-rg
```

## Alternative: Use Azure Container Instances (ACI) Without Quota Issues

If you don't want to wait for quota approval, use ACI instead:

```bash
az container create \
  --resource-group ecommerce-rg \
  --name ecommerce-app \
  --image ecommerceacr2025.azurecr.io/ecommerce-app:latest \
  --registry-login-server ecommerceacr2025.azurecr.io \
  --registry-username ecommerceacr2025 \
  --registry-password GLHj8295jwvBYCErzYSazjm2Grmr8mUzXgCwDBjryVbirTYsYTQbJQQJ99CDACYeBjFEqg7NAAACAZCRB5mM \
  --ports 80 \
  --dns-name-label ecommerce-app-$(date +%s) \
  --cpu 1 \
  --memory 1
```

Then get the access URL:
```bash
az container show --resource-group ecommerce-rg --name ecommerce-app --query ipAddress.fqdn
```
