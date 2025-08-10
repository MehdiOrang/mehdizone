````markdown
# Running Multiple Apps on Kubernetes

This guide will walk you through the steps required to run your **6 apps** (3 backend and frontend together) on a **Kubernetes** cluster. The steps include creating Docker images, setting up Kubernetes deployments and services, and managing the apps locally using **Minikube** or on a cloud provider using **AWS EKS**, **Google GKE**, or **Azure AKS**.

---

## Prerequisites

Before getting started, ensure you have the following tools installed:

1. **Minikube**: [Minikube Installation Guide](https://minikube.sigs.k8s.io/docs/)
2. **kubectl**: [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
3. **Docker**: [Install Docker](https://www.docker.com/get-started)
4. **Cloud Provider Setup** (Optional): If you're using a cloud provider (AWS, GCP, Azure), you’ll need to set up a Kubernetes cluster (EKS, GKE, AKS).

---

## Step 1: Set Up a Kubernetes Cluster

### Using Minikube (Local Setup)

1. **Start Minikube**:
   Launch a local Kubernetes cluster using Minikube:
   ```bash
   minikube start
````

2. **Verify Kubernetes Cluster**:
   Ensure that your Minikube cluster is running:

   ```bash
   kubectl cluster-info
   ```

### Using Cloud Provider (AWS EKS, GKE, or AKS)

1. **Create a Kubernetes Cluster**:

   * **AWS EKS**: [EKS Getting Started](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)
   * **Google GKE**: [GKE Getting Started](https://cloud.google.com/kubernetes-engine/docs/quickstarts)
   * **Azure AKS**: [AKS Getting Started](https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-cluster)

2. **Configure kubectl**:
   After setting up the cluster, configure `kubectl` to use your cloud cluster:

   ```bash
   aws eks --region <region> update-kubeconfig --name <cluster-name>
   # For GKE
   gcloud container clusters get-credentials <cluster-name> --zone <zone> --project <project-id>
   # For AKS
   az aks get-credentials --resource-group <resource-group> --name <aks-cluster-name>
   ```

---

## Step 2: Build Docker Images for Each App

You need to build Docker images for your **frontends** and **backends**.

### For React + Node.js Backend

1. **React Dockerfile** (`frontend-react/Dockerfile`):

   ```Dockerfile
   # Step 1: Build the React app
   FROM node:16-alpine AS build
   WORKDIR /app
   COPY . .
   RUN npm install
   RUN npm run build

   # Step 2: Serve the React app
   FROM nginx:alpine
   COPY --from=build /app/build /usr/share/nginx/html
   EXPOSE 80
   CMD ["nginx", "-g", "daemon off;"]
   ```

2. **Node.js Backend Dockerfile** (`backend-react/Dockerfile`):

   ```Dockerfile
   FROM node:16-alpine
   WORKDIR /app
   COPY . .
   RUN npm install
   EXPOSE 3000
   CMD ["node", "server.js"]
   ```

3. **Build the Docker images**:

   ```bash
   docker build -t react-frontend ./frontend-react
   docker build -t node-backend ./backend-react
   ```

### For Angular + Python Flask Backend

1. **Angular Dockerfile** (`frontend-angular/Dockerfile`):

   ```Dockerfile
   FROM node:16-alpine AS build
   WORKDIR /app
   COPY . .
   RUN npm install
   RUN npm run build --prod

   FROM nginx:alpine
   COPY --from=build /app/dist /usr/share/nginx/html
   EXPOSE 80
   CMD ["nginx", "-g", "daemon off;"]
   ```

2. **Python Flask Backend Dockerfile** (`backend-angular/Dockerfile`):

   ```Dockerfile
   FROM python:3.9-slim
   WORKDIR /app
   COPY . .
   RUN pip install -r requirements.txt
   EXPOSE 5000
   CMD ["python", "app.py"]
   ```

3. **Build the Docker images**:

   ```bash
   docker build -t angular-frontend ./frontend-angular
   docker build -t python-backend ./backend-angular
   ```

### For Vue.js + Laravel Backend

1. **Vue.js Dockerfile** (`frontend-vue/Dockerfile`):

   ```Dockerfile
   FROM node:16-alpine AS build
   WORKDIR /app
   COPY . .
   RUN npm install
   RUN npm run build

   FROM nginx:alpine
   COPY --from=build /app/dist /usr/share/nginx/html
   EXPOSE 80
   CMD ["nginx", "-g", "daemon off;"]
   ```

2. **Laravel Backend Dockerfile** (`backend-vue/Dockerfile`):

   ```Dockerfile
   FROM php:7.4-fpm
   WORKDIR /var/www
   COPY . .
   RUN composer install
   EXPOSE 8000
   CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
   ```

3. **Build the Docker images**:

   ```bash
   docker build -t vue-frontend ./frontend-vue
   docker build -t laravel-backend ./backend-vue
   ```

---

## Step 3: Create Kubernetes Deployment Files

Each application (frontend and backend) needs a **Deployment** to run in Kubernetes, and a **Service** to expose it.

### Example Kubernetes Deployment for React + Node.js

Create a `react-node-deployment.yml` for the **React frontend** and **Node.js backend**:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: react-frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: react-frontend
  template:
    metadata:
      labels:
        app: react-frontend
    spec:
      containers:
        - name: react-frontend
          image: react-frontend:latest
          ports:
            - containerPort: 80

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: node-backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: node-backend
  template:
    metadata:
      labels:
        app: node-backend
    spec:
      containers:
        - name: node-backend
          image: node-backend:latest
          ports:
            - containerPort: 3000
```

### Example Kubernetes Service for React + Node.js

```yaml
apiVersion: v1
kind: Service
metadata:
  name: react-frontend
spec:
  selector:
    app: react-frontend
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer

---
apiVersion: v1
kind: Service
metadata:
  name: node-backend
spec:
  selector:
    app: node-backend
  ports:
    - protocol: TCP
      port: 3000
      targetPort: 3000
  type: LoadBalancer
```

Repeat this process for the **Angular + Python** and **Vue.js + Laravel** stacks, modifying the deployment and service names accordingly.

---

## Step 4: Apply Deployments and Services to Kubernetes

1. **Apply the Deployment Files**:
   Run the following command to apply each deployment file:

   ```bash
   kubectl apply -f react-node-deployment.yml
   kubectl apply -f angular-python-deployment.yml
   kubectl apply -f vue-laravel-deployment.yml
   ```

2. **Verify Deployments**:
   Check if all pods are running correctly:

   ```bash
   kubectl get pods
   ```

3. **Expose Services**:
   After the deployments are created, the services will be automatically exposed based on the `type: LoadBalancer` in the service definition.

   You can verify the services with:

   ```bash
   kubectl get svc
   ```

   * **For Minikube**: If you're using Minikube, run `minikube service react-frontend` to open the service in your browser.
   * **For Cloud**: Use the external IP provided by your cloud service provider.

---

## Step 5: Scaling and Managing Your Apps

To scale your deployments (e.g., running multiple replicas of a frontend), you can use the following command:

```bash
kubectl scale deployment react-frontend --replicas=3
```

This will create 3 replicas of your React frontend, allowing your application to handle more traffic.

---

## Step 6: Clean Up

To delete all the resources you created:

```bash
kubectl delete -f react-node-deployment.yml
kubectl delete -f angular-python-deployment.yml
kubectl delete -f vue-laravel-deployment.yml
```

---

