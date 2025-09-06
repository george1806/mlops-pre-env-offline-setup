# 🚀 Harbor Installation on Kubernetes Env

This guide explains how to install [Harbor](https://goharbor.io/) as a private container registry inside your Kubernetes cluster.  
Harbor will serve as your **offline image registry**, allowing you to push and pull container images without internet access.

---

## 📂 Directory Structure

```sh
apps/
  harbor/
    charts/                # Harbor Helm chart goes here (untarred)
    scripts/
      10-install.sh        # Installation script
    values/
      harbor-values.yaml   # Template values file (placeholders)
    .env.local             # Local environment variables
```

## 🔧 Step 1: Download Harbor Helm Chart

```sh
helm repo add harbor https://helm.goharbor.io
helm repo update
helm pull harbor/harbor --version 1.15.1 --untar
```

This creates a folder named harbor/.
Move it into your project:

```sh
mkdir -p apps/harbor/charts
mv harbor apps/harbor/charts/

```

## 🔑 Step 2: Create .env.local

apps/harbor/.env.local

```ts
HARBOR_ADMIN_PASSWORD=
HARBOR_EXTERNAL_URL=
```

## ⚙️ Step 3: Configure Helm Values

## 📝 Step 4: Review Installation Script

## 🚦 Step 5: Run the Installation

```sh
chmod +x apps/harbor/scripts/10-install.sh
./apps/harbor/scripts/10-install.sh
```

## 🔍 Step 6: Verify Deployment

```sh
kubectl get pods -n harbor
```

## 🌐 Step 7: Access Harbor

```sh
http://<your-node-ip>:30002
```
