# Live Demo Script for Nishanth

This script provides step-by-step instructions for the live demo.

## Preparation (Before Demo)

1. Ensure Docker is running
2. Ensure Minikube is started: `minikube start`
3. Have terminal and browser ready
4. Have all commands prepared in separate terminal tabs

## Demo Part 1: Docker Compose (5 minutes)

### Show the Application Running Locally

**Terminal Commands:**
```bash
cd /Users/nishanthkotla/Desktop/Cloud/Assign_2

# Show the docker-compose file
cat docker-compose.yml

# Start the application
docker-compose up -d

# Show running containers
docker ps

# Show container logs
docker-compose logs flask-app
```

**Browser:**
- Open http://localhost:5000
- Add a new task: "Demo Task 1" with description "Testing Docker Compose"
- Set priority to "High"
- Mark it as complete
- Show the completed tasks view

**Terminal (continued):**
```bash
# Show MongoDB container is running
docker-compose ps

# Clean up
docker-compose down
```

**Screenshot Checklist:**
- [ ] `docker ps` output showing both containers
- [ ] Browser showing application homepage
- [ ] Browser showing a created task
- [ ] `docker-compose logs` output

## Demo Part 2: Minikube Deployment (10 minutes)

### Deploy to Minikube

**Terminal Commands:**
```bash
# Check Minikube status
minikube status

# Show Kubernetes configs
ls -la k8s/

# Deploy MongoDB
kubectl apply -f k8s/mongodb-deployment.yaml
kubectl apply -f k8s/mongodb-service.yaml

# Check MongoDB deployment
kubectl get pods -l app=mongodb
kubectl get svc mongodb

# Deploy Flask app
kubectl apply -f k8s/flask-deployment.yaml
kubectl apply -f k8s/flask-service.yaml

# Show all resources
kubectl get all

# Show detailed pods
kubectl get pods -o wide

# Show ReplicaSets
kubectl get rs

# Get service URL
minikube service flask-todo-service --url
```

**Browser:**
- Open the Minikube service URL
- Add multiple tasks to demonstrate the application works
- Show different views (All, Completed, Uncompleted)

**Screenshot Checklist:**
- [ ] `kubectl get all` output
- [ ] `kubectl get pods` showing 3 replicas
- [ ] `kubectl get rs` output
- [ ] Browser showing app on Minikube URL
- [ ] Tasks created on Minikube

## Demo Part 3: ReplicaSet Auto-Recovery (5 minutes)

### Test Pod Deletion and Recovery

**Terminal Commands:**
```bash
# Show current pods
kubectl get pods

# Count pods
kubectl get pods -l app=flask-todo-app --no-headers | wc -l

# Delete one pod (copy actual pod name)
kubectl delete pod flask-todo-app-xxxxx-xxxxx

# Immediately watch recovery
kubectl get pods -l app=flask-todo-app -w
```

**Explanation Points:**
- Kubernetes maintains desired state (3 replicas)
- When pod is deleted, ReplicaSet controller creates new pod
- Application remains available during pod replacement
- This is self-healing capability

**Terminal (continue after pod recovers):**
```bash
# Press Ctrl+C to stop watching

# Show ReplicaSet events
kubectl describe rs flask-todo-app-xxxxx

# Show final state
kubectl get pods
```

**Screenshot Checklist:**
- [ ] Before deletion: 3 pods running
- [ ] During recovery: pod terminating and new pod creating
- [ ] After recovery: 3 pods running again
- [ ] `kubectl describe rs` showing events

## Demo Part 4: Scaling Up and Down (5 minutes)

### Scale to 5 Replicas

**Terminal Commands:**
```bash
# Show current replicas
kubectl get deployment flask-todo-app

# Scale up to 5
kubectl scale deployment flask-todo-app --replicas=5

# Watch pods being created
kubectl get pods -w -l app=flask-todo-app
```

**Wait for all 5 pods to be running, then press Ctrl+C**

```bash
# Show all 5 pods
kubectl get pods -l app=flask-todo-app

# Show ReplicaSet
kubectl get rs
```

### Scale Down to 2 Replicas

**Terminal Commands:**
```bash
# Scale down to 2
kubectl scale deployment flask-todo-app --replicas=2

# Watch pods terminating
kubectl get pods -l app=flask-todo-app

# Show final state
kubectl get rs
```

### Scale Back to Original

**Terminal Commands:**
```bash
# Scale back to 3
kubectl scale deployment flask-todo-app --replicas=3

# Verify
kubectl get pods
kubectl get rs
```

**Screenshot Checklist:**
- [ ] 5 pods running after scale up
- [ ] `kubectl get rs` showing 5/5 ready
- [ ] 2 pods running after scale down
- [ ] Back to 3 pods

## Demo Part 5: Additional Commands (If Time Permits)

### Show Pod Details

**Terminal Commands:**
```bash
# Pick one pod and show details
kubectl describe pod flask-todo-app-xxxxx-xxxxx

# Show pod logs
kubectl logs flask-todo-app-xxxxx-xxxxx

# Show deployment details
kubectl describe deployment flask-todo-app
```

### Show Kubernetes Dashboard (Optional)

**Terminal Commands:**
```bash
# Open dashboard
minikube dashboard
```

## Talking Points During Demo

### Docker Compose Section:
- Two containers: Flask app and MongoDB
- Volume for data persistence
- Network isolation
- Environment variables for configuration
- Easy local development setup

### Minikube Section:
- Kubernetes runs locally via Minikube
- Deployments manage ReplicaSets
- ReplicaSets manage Pods
- Services provide load balancing
- NodePort exposes application externally
- PersistentVolumeClaim for MongoDB data

### ReplicaSet Section:
- Desired state vs actual state
- Self-healing capability
- High availability
- No downtime during pod replacement
- Automatic load distribution

### Scaling Section:
- Horizontal scaling
- Dynamic resource allocation
- Load balancing across replicas
- Easy scale up/down for traffic changes
- Zero downtime scaling

## Troubleshooting During Demo

### If pods are not starting:
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### If service is not accessible:
```bash
kubectl get svc
minikube service list
minikube service flask-todo-service --url
```

### If Minikube is not running:
```bash
minikube start --driver=docker
```

## After Demo

**Cleanup (Optional):**
```bash
# Delete deployments
kubectl delete -f k8s/

# Stop Minikube
minikube stop

# Stop Docker Compose (if still running)
docker-compose down
```

## Time Allocation

- Docker Compose: 5 minutes
- Minikube Deployment: 10 minutes  
- ReplicaSet Testing: 5 minutes
- Scaling: 5 minutes
- Q&A Buffer: 5 minutes

**Total: 30 minutes**

