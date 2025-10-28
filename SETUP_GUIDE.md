# Flask Todo Application - Deployment Guide

This guide covers the complete setup for Nishanth's part of the assignment.

## Prerequisites

- Docker installed and running
- Minikube installed
- kubectl installed
- Docker Hub account

## Part 1: Application Setup

The Flask + MongoDB To-Do application is already set up with:
- `app.py` - Main Flask application
- `templates/` - HTML templates
- `static/` - CSS, JS, and images
- `requirements.txt` - Python dependencies

## Part 2: Containerizing with Docker

### Step 1: Build Docker Image

```bash
cd /Users/nishanthkotla/Desktop/Cloud/Assign_2
docker build -t flask-todo-app:latest .
```

### Step 2: Test Locally with Docker Compose

```bash
docker-compose up -d
```

Access the application at: http://localhost:5000

To view logs:
```bash
docker-compose logs -f
```

To stop:
```bash
docker-compose down
```

### Step 3: Push to Docker Hub

```bash
# Login to Docker Hub
docker login

# Tag the image with your Docker Hub username
docker tag flask-todo-app:latest your-dockerhub-username/flask-todo-app:latest

# Push to Docker Hub
docker push your-dockerhub-username/flask-todo-app:latest
```

## Part 3: Minikube Deployment

### Step 1: Start Minikube

```bash
minikube start --driver=docker
```

Verify Minikube is running:
```bash
minikube status
```

### Step 2: Update Kubernetes Configuration

Before deploying, update the image name in `k8s/flask-deployment.yaml`:
- Replace `your-dockerhub-username` with your actual Docker Hub username

### Step 3: Deploy MongoDB

```bash
kubectl apply -f k8s/mongodb-deployment.yaml
kubectl apply -f k8s/mongodb-service.yaml
```

Verify MongoDB is running:
```bash
kubectl get pods -l app=mongodb
kubectl get svc mongodb
```

### Step 4: Deploy Flask Application

```bash
kubectl apply -f k8s/flask-deployment.yaml
kubectl apply -f k8s/flask-service.yaml
```

Verify deployment:
```bash
kubectl get deployments
kubectl get pods
kubectl get services
```

### Step 5: Access the Application

Get the Minikube URL:
```bash
minikube service flask-todo-service --url
```

Open the URL in your browser.

## Part 5: ReplicaSets Testing

### View Current ReplicaSets

```bash
kubectl get rs
kubectl describe rs
```

### Test 1: Pod Deletion and Auto Recovery

Delete a pod and watch Kubernetes automatically create a replacement:

```bash
# Get pod names
kubectl get pods

# Delete one pod (replace with actual pod name)
kubectl delete pod flask-todo-app-xxxxx-xxxxx

# Watch pods recover
kubectl get pods -w
```

You should see a new pod being created automatically to maintain the desired count of 3 replicas.

### Test 2: Scale Up

Scale to 5 replicas:

```bash
kubectl scale deployment flask-todo-app --replicas=5
kubectl get pods
kubectl get rs
```

### Test 3: Scale Down

Scale back to 2 replicas:

```bash
kubectl scale deployment flask-todo-app --replicas=2
kubectl get pods
```

### Test 4: Update Deployment YAML

Edit `k8s/flask-deployment.yaml` and change `replicas: 3` to `replicas: 4`, then:

```bash
kubectl apply -f k8s/flask-deployment.yaml
kubectl get pods
```

## Useful Commands

### Docker Commands

```bash
# View running containers
docker ps

# View images
docker images

# Stop all containers
docker-compose down

# Remove image
docker rmi flask-todo-app:latest
```

### Kubernetes Commands

```bash
# View all resources
kubectl get all

# View pod logs
kubectl logs <pod-name>

# Describe pod
kubectl describe pod <pod-name>

# Delete deployment
kubectl delete deployment flask-todo-app

# Delete service
kubectl delete service flask-todo-service

# Access pod shell
kubectl exec -it <pod-name> -- /bin/bash
```

### Minikube Commands

```bash
# Start Minikube
minikube start

# Stop Minikube
minikube stop

# Delete Minikube cluster
minikube delete

# Open Kubernetes dashboard
minikube dashboard

# SSH into Minikube
minikube ssh
```

## Troubleshooting

### Issue: Cannot access application

Check if pods are running:
```bash
kubectl get pods
```

Check pod logs:
```bash
kubectl logs <pod-name>
```

### Issue: ImagePullBackOff

Make sure:
1. You pushed the image to Docker Hub
2. The image name in deployment.yaml is correct
3. The image is public or you have proper credentials

### Issue: CrashLoopBackOff

Check logs for errors:
```bash
kubectl logs <pod-name>
```

Common causes:
- MongoDB service not ready
- Incorrect environment variables
- Application code errors

## Screenshots to Capture for Documentation

1. Docker Compose:
   - `docker-compose ps` output
   - Browser showing application running on localhost:5000
   - `docker ps` showing containers

2. Minikube Deployment:
   - `kubectl get all` output
   - `kubectl get pods` showing all replicas
   - Browser showing application on Minikube URL
   - `kubectl get rs` showing ReplicaSet

3. ReplicaSet Testing:
   - Before and after pod deletion
   - Scaling up to 5 replicas
   - Scaling down to 2 replicas

4. Logs:
   - `kubectl logs` from a Flask pod
   - `minikube service list` output

