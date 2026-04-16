# 🚀 Quick Start Guide: Deploy ACR & AKS

This guide will get you running the Azure pipeline with ACR and AKS in minutes.

## ⚡ Quick Steps

### Step 1: Deploy Infrastructure (5-10 minutes)

Open PowerShell and run:

```powershell
cd d:\Ecommerce-Website
.\deploy-acr-aks.ps1
```

This will:
- ✅ Create resource group `ecommerce-rg`
- ✅ Deploy ACR (Azure Container Registry)
- ✅ Deploy AKS (Azure Kubernetes Service) 
- ✅ Configure kubectl access
- 📋 Display outputs you'll need

**Save the outputs!** You'll need:
- ACR Name
- ACR Login Server
- AKS Cluster Name

### Step 2: Create Service Connections in Azure DevOps (5 minutes)

1. Go to **Azure DevOps** → Your Project → **Project Settings**

2. Go to **Service Connections**

3. **Create ACR Connection:**
   - Click **New Service Connection** → **Docker Registry**
   - Registry type: **Azure Container Registry**
   - Subscription: Your Azure subscription
   - Azure Container Registry: `ecommerce<random>`
   - Name: **`ACRConnection`**
   - Click **Save**

4. **Create AKS Connection:**
   - Click **New Service Connection** → **Kubernetes**
   - Authentication: **Azure Subscription**
   - Subscription: Your Azure subscription
   - Resource Group: **`ecommerce-rg`**
   - AKS cluster: **`ecommerce-aks-prod`**
   - Name: **`ecommerce-aks`**
   - Click **Save**

5. **Create SonarQube Connection (Optional):**
   - Click **New Service Connection** → **Generic**
   - Enter your SonarQube details
   - Name: **`SonarQube`**
   - Click **Save**

### Step 3: Run the Pipeline (2 minutes)

1. Go to **Pipelines** in Azure DevOps
2. Select **azure-pipelines.yml**
3. Click **Run Pipeline**
4. Watch the stages:
   - 🏗️ Build: Analysis & Docker build
   - 📦 Deploy: Push to ACR & Deploy to AKS
   - ✅ Validate: Verify deployment

### Step 4: Access Your Application (1 minute)

```powershell
# Get the external IP
kubectl get service ecommerce-app

# Visit the LoadBalancer External IP in browser
# http://<EXTERNAL-IP>
```

## 📋 Files Created/Modified

| File | Purpose |
|------|---------|
| `infra/main.bicep` | Infrastructure as Code for ACR & AKS |
| `infra/parameters.bicepparam` | Deployment parameters |
| `deploy-acr-aks.ps1` | Automated deployment script |
| `azure-pipelines.yml` | Updated CI/CD pipeline |
| `k8s-deployment.yaml` | Updated Kubernetes deployment |
| `k8s-service.yaml` | Updated Kubernetes service |
| `SETUP_ACR_AKS.md` | Detailed setup guide |
| `QUICK_START.md` | This file |

## 🔍 Verify Everything Works

```powershell
# Check AKS cluster
kubectl cluster-info
kubectl get nodes
kubectl get pods -A

# Check ACR
az acr repository list --name <ACR_NAME> --output table

# Check deployment
kubectl get deployments
kubectl get services
kubectl logs deployment/ecommerce-app
```

## ❌ Troubleshooting

### Pipeline Fails to Connect to ACR
- Verify `ACRConnection` service connection exists
- Check connection is using correct ACR name
- Verify authentication credentials

### AKS Deployment Fails
- Check `ecommerce-aks` service connection
- Verify AKS cluster is running: `kubectl cluster-info`
- Check pod logs: `kubectl logs pod/<pod-name>`

### Image Pull Fails
- Check image pulls secret: `kubectl get secrets`
- Verify ACR credentials: `az acr credential show -n <ACR_NAME>`

### Application Not Accessible
- Check service type: `kubectl get service ecommerce-app`
- Check if LoadBalancer IP is assigned (may take 1-2 minutes)
- Verify health check endpoint `/health.html` exists

## 📚 More Information

- Detailed setup: [SETUP_ACR_AKS.md](SETUP_ACR_AKS.md)
- Kubernetes deployments: [k8s-deployment.yaml](k8s-deployment.yaml)
- Infrastructure code: [infra/main.bicep](infra/main.bicep)
- CI/CD pipeline: [azure-pipelines.yml](azure-pipelines.yml)

## 🆘 Need Help?

1. Check outputs from `deploy-acr-aks.ps1`
2. Review logs in Azure DevOps pipeline
3. Test kubectl connection: `kubectl cluster-info`
4. Check AKS node status: `kubectl get nodes -o wide`

---

**That's it!** Your CI/CD pipeline is ready to deploy containerized applications to AKS! 🎉
