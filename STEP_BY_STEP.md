# Step-by-Step Execution Guide

Follow these steps in order to complete all of Nishanth's assignment tasks.

## Prerequisites Check

```bash
# Check Docker
docker --version
docker-compose --version

# Check if Docker is running
docker ps
```

## Part 1: Application Setup (Already Done)

The Flask + MongoDB application source code is already provided.

## Part 2: Containerizing with Docker

### Step 1: Build Docker Image

```bash
cd /Users/nishanthkotla/Desktop/Cloud/Assign_2

# Build the image
docker build -t flask-todo-app:latest .

# Verify image is created
docker images | grep flask-todo-app
```

**Take Screenshot:** Docker images list

### Step 2: Test with Docker Compose

```bash
# Start containers
docker-compose up -d

# Check containers are running
docker-compose ps
docker ps

# View logs
docker-compose logs -f flask-app
```

**Take Screenshot:** docker-compose ps output

### Step 3: Test Application Locally

Open browser: http://localhost:5000

- Create a task: "Test Task 1"
- Add description, date, and priority
- Mark it as complete
- Test the search function
- View completed/uncompleted tasks

**Take Screenshots:**
- Homepage with tasks
- Task creation form
- Completed tasks view

### Step 4: Stop Containers

```bash
# Stop but keep data
docker-compose down

# To remove volumes too (clean slate)
docker-compose down -v
```

### Step 5: Push to Docker Hub

First, you need a Docker Hub account. Sign up at https://hub.docker.com if you don't have one.

```bash
# Login to Docker Hub
docker login
# Enter your username and password when prompted

# Run the build and push script
./build-and-push.sh <your-dockerhub-username>

# Or manually:
docker tag flask-todo-app:latest <your-dockerhub-username>/flask-todo-app:latest
docker push <your-dockerhub-username>/flask-todo-app:latest
```

**Take Screenshot:** Docker Hub repository page showing the image

### Step 6: Update Kubernetes Deployment File

```bash
# Update deployment file with your Docker Hub username
./update-dockerhub-username.sh <your-dockerhub-username>

# Or manually edit k8s/flask-deployment.yaml
# Change: your-dockerhub-username/flask-todo-app:latest
# To: <your-actual-username>/flask-todo-app:latest
```

## Part 3: Minikube Deployment

### Step 1: Install Minikube (if not installed)

**On macOS:**
```bash
brew install minikube
```

**On Linux:**
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

**On Windows:**
Download from: https://minikube.sigs.k8s.io/docs/start/

### Step 2: Start Minikube

```bash
# Start Minikube with Docker driver
minikube start --driver=docker

# Verify it's running
minikube status
```

**Take Screenshot:** minikube status output

### Step 3: Deploy MongoDB

```bash
# Apply MongoDB deployment and service
kubectl apply -f k8s/mongodb-deployment.yaml
kubectl apply -f k8s/mongodb-service.yaml

# Check MongoDB pod
kubectl get pods -l app=mongodb

# Wait for MongoDB to be ready
kubectl wait --for=condition=ready pod -l app=mongodb --timeout=120s

# Check PVC
kubectl get pvc
```

**Take Screenshot:** kubectl get pods showing MongoDB

### Step 4: Deploy Flask Application

```bash
# Apply Flask deployment and service
kubectl apply -f k8s/flask-deployment.yaml
kubectl apply -f k8s/flask-service.yaml

# Check all resources
kubectl get all

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app=flask-todo-app --timeout=120s
```

**Take Screenshots:**
- kubectl get all
- kubectl get pods -o wide
- kubectl get rs

### Step 5: Access Application on Minikube

```bash
# Get service URL
minikube service flask-todo-service --url

# Or open in browser directly
minikube service flask-todo-service
```

**Take Screenshot:** Browser showing application on Minikube URL

### Step 6: Test Application

- Create multiple tasks
- Test all functionality
- Verify data persists

**Take Screenshot:** Application with tasks created

## Part 5: ReplicaSets Testing

### Test 1: View Initial State

```bash
# View deployments
kubectl get deployments

# View ReplicaSets
kubectl get rs

# View pods
kubectl get pods -l app=flask-todo-app

# Describe ReplicaSet
kubectl describe rs
```

**Take Screenshot:** kubectl get pods showing 3 replicas

### Test 2: Pod Deletion and Auto-Recovery

```bash
# Method 1: Use the script
./test-replicaset.sh

# Method 2: Manual
# Get pod name
kubectl get pods -l app=flask-todo-app

# Delete one pod (replace with actual pod name)
kubectl delete pod flask-todo-app-xxxxx-xxxxx

# Watch recovery happen in real-time
kubectl get pods -l app=flask-todo-app -w
# Press Ctrl+C to stop watching
```

**Take Screenshots:**
- Before deletion: 3 pods
- During recovery: pod terminating and new pod creating
- After recovery: 3 pods again with new pod name

### Test 3: Scale Up to 5 Replicas

```bash
# Scale up
kubectl scale deployment flask-todo-app --replicas=5

# Watch pods being created
kubectl get pods -l app=flask-todo-app -w
# Press Ctrl+C when all 5 are running

# Check ReplicaSet
kubectl get rs
```

**Take Screenshots:**
- 5 pods running
- kubectl get rs showing 5/5

### Test 4: Scale Down to 2 Replicas

```bash
# Scale down
kubectl scale deployment flask-todo-app --replicas=2

# Check pods
kubectl get pods -l app=flask-todo-app

# Check ReplicaSet
kubectl get rs
```

**Take Screenshot:** 2 pods running

### Test 5: Scale Back to Original (3 Replicas)

```bash
# Scale to 3
kubectl scale deployment flask-todo-app --replicas=3

# Verify
kubectl get pods -l app=flask-todo-app
kubectl get rs
```

**Take Screenshot:** Back to 3 pods

### Test 6: Using the Scale Test Script

```bash
# This automates all scaling tests
./scale-test.sh
```

**Take Screenshots:** Each scaling stage

### Test 7: Verify Application During Scaling

During scaling operations, the application should remain accessible. Test by:

```bash
# In one terminal, watch pods
kubectl get pods -l app=flask-todo-app -w

# In another terminal, repeatedly curl or open browser
curl $(minikube service flask-todo-service --url)
```

## Additional Verification Commands

### Check Deployment Details

```bash
kubectl describe deployment flask-todo-app
```

Shows:
- Replicas configuration
- Scaling history
- Pod template
- Events

### Check Pod Logs

```bash
# Get pod name
kubectl get pods

# View logs
kubectl logs <pod-name>

# Follow logs
kubectl logs -f <pod-name>
```

### Check Service Details

```bash
kubectl describe service flask-todo-service
```

### Check Events

```bash
kubectl get events --sort-by='.lastTimestamp'
```

### Open Kubernetes Dashboard

```bash
minikube dashboard
```

## Cleanup (After Demo/Testing)

### Stop Application but Keep Minikube

```bash
kubectl delete -f k8s/flask-deployment.yaml
kubectl delete -f k8s/flask-service.yaml
kubectl delete -f k8s/mongodb-deployment.yaml
kubectl delete -f k8s/mongodb-service.yaml
```

### Stop Minikube

```bash
minikube stop
```

### Delete Minikube Cluster (Complete Reset)

```bash
minikube delete
```

### Stop Docker Compose

```bash
docker-compose down
docker-compose down -v  # Also remove volumes
```

## Troubleshooting

### Problem: Pods not starting (ImagePullBackOff)

```bash
# Check pod details
kubectl describe pod <pod-name>

# Common fix: Update image name in deployment
kubectl edit deployment flask-todo-app
```

### Problem: Pods crashing (CrashLoopBackOff)

```bash
# Check logs
kubectl logs <pod-name>

# Usually MongoDB not ready - wait and check
kubectl get pods -l app=mongodb
```

### Problem: Cannot access application

```bash
# Check service
kubectl get svc

# Get URL again
minikube service flask-todo-service --url

# Check if Minikube is running
minikube status
```

### Problem: Docker build fails

```bash
# Check Dockerfile syntax
cat Dockerfile

# Build with no cache
docker build --no-cache -t flask-todo-app:latest .
```

## Summary Checklist

- [ ] Docker image built successfully
- [ ] Docker Compose tested locally
- [ ] Image pushed to Docker Hub
- [ ] Minikube started
- [ ] MongoDB deployed on Minikube
- [ ] Flask app deployed on Minikube
- [ ] Application accessible via browser
- [ ] ReplicaSet with 3 pods verified
- [ ] Pod deletion and auto-recovery tested
- [ ] Scale up to 5 replicas tested
- [ ] Scale down to 2 replicas tested
- [ ] All screenshots captured
- [ ] Documentation completed

## Running Comprehensive Tests

### Automated Test Suite

A comprehensive test suite (`test-all.sh`) is provided that tests all assignment components:

```bash
cd /Users/nishanthkotla/Desktop/Cloud/Assign_2
./test-all.sh
```

The test suite covers:
- ✓ Prerequisites (Docker, Minikube, kubectl)
- ✓ Kubernetes resources (pods, services, deployments, ReplicaSets, PVC)
- ✓ Pod health checks and logs
- ✓ Todo app functionality (all endpoints, static files, task creation)
- ✓ ReplicaSet auto-recovery
- ✓ Scaling operations (up to 5, down to 2, back to 3)
- ✓ Resource configuration

Expected Output: **28/28 tests passed (100%)**

### Manual Verification

You can also verify individual components:

```bash
# Check all resources
kubectl get all

# Check pods are running
kubectl get pods

# Test the application
kubectl port-forward svc/flask-todo-service 8080:5000 &
curl http://localhost:8080
pkill -f "kubectl port-forward"

# Check ReplicaSet
kubectl get rs
kubectl describe rs

# Test scaling
kubectl scale deployment flask-todo-app --replicas=5
kubectl get pods
kubectl scale deployment flask-todo-app --replicas=3
```

## Next Steps for Yoga (AWS EKS Parts)

The Docker Hub image you created will be used by Yoga for:
- Part 4: AWS EKS Deployment
- Part 6: Rolling Updates
- Part 7: Health Monitoring
- Part 8: Alerting (Extra Credit)

Make sure to share your Docker Hub image name with Yoga.

