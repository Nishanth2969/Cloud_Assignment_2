# Cloud Assignment 2 - Kubernetes Deployment

Flask + MongoDB To-Do Application deployed on Docker and Kubernetes (Minikube)

## Assignment Overview

This project demonstrates containerization and orchestration of a web application using Docker, Docker Compose, and Kubernetes. It covers local development with Docker Compose and deployment on Minikube with ReplicaSets and scaling capabilities.

## Team

Nishanth Kotla (nk3968@nyu.edu)
Yoga Sathyanarayanan (ys6678@nyu.edu)

## Technology Stack

- **Backend**: Flask (Python 3.9)
- **Database**: MongoDB 5.0
- **Containerization**: Docker, Docker Compose
- **Orchestration**: Kubernetes (Minikube)
- **Registry**: Docker Hub

## Project Structure

```
.
├── app.py                      # Flask application
├── requirements.txt            # Python dependencies
├── Dockerfile                  # Docker image configuration
├── docker-compose.yml          # Docker Compose setup
├── templates/                  # HTML templates
├── static/                     # CSS, JS, images
├── k8s/                       # Kubernetes manifests
│   ├── mongodb-deployment.yaml
│   ├── mongodb-service.yaml
│   ├── flask-deployment.yaml
│   └── flask-service.yaml
├── test-all.sh                # Comprehensive test suite
├── validate-setup.sh          # Setup validation
├── deploy-minikube.sh         # Minikube deployment script
├── build-and-push.sh          # Docker Hub push script
└── documentation/             # Detailed guides
```

## Quick Start

### Prerequisites

- Docker Desktop
- Minikube
- kubectl
- Docker Hub account (for image push)

### Local Testing with Docker Compose

```bash
# Build and start services
docker-compose up -d

# Access application
open http://localhost:5001

# Stop services
docker-compose down
```

### Deploy to Minikube

```bash
# Start Minikube
minikube start --driver=docker

# Deploy application
./deploy-minikube.sh

# Access application
minikube service flask-todo-service
```

### Run Comprehensive Tests

```bash
./test-all.sh
```

Expected: **28/28 tests pass (100%)**

## Features

- Create, read, update, delete tasks
- Mark tasks as complete/incomplete
- Filter by status (all, completed, uncompleted)
- Search tasks by various fields
- Set priority levels
- Due date management
- Persistent data storage with MongoDB
- Input validation with error messages
- Exception handling for invalid data

## Kubernetes Features Implemented

- **Deployments**: Flask app with 3 replicas, MongoDB with persistent storage
- **Services**: NodePort for external access, ClusterIP for internal communication
- **ReplicaSets**: Automatic pod management and recovery
- **Scaling**: Dynamic horizontal scaling (tested 2-5 replicas)
- **Persistent Volumes**: MongoDB data persistence
- **Resource Limits**: Memory and CPU constraints configured

## Testing

The project includes comprehensive automated testing:

```bash
./test-all.sh
```

Tests cover:
- Prerequisites validation
- Kubernetes resources verification
- Pod health checks
- Application functionality (all endpoints)
- ReplicaSet auto-recovery
- Scaling operations
- Resource configuration

## Documentation

- `README.md` - This file (project overview and quick start guide)
- `Cloud Documentation.pdf` - Complete assignment documentation with screenshots
- `Cloud Documentation.docx` - Editable version of the documentation

## Key Commands

### Docker

```bash
# Build image
docker build -t flask-todo-app:latest .

# Run with Docker Compose
docker-compose up -d

# Push to Docker Hub
./build-and-push.sh <your-dockerhub-username>
```

### Kubernetes

```bash
# Validate setup
./validate-setup.sh

# Deploy to Minikube
./deploy-minikube.sh

# Check status
kubectl get all

# Scale deployment
kubectl scale deployment flask-todo-app --replicas=5

# View logs
kubectl logs -l app=flask-todo-app

# Access application
minikube service flask-todo-service
```

## Assignment Completion Status

### Part 1: Application Setup [COMPLETE]
- Flask + MongoDB To-Do app configured and working

### Part 2: Docker Containerization [COMPLETE]
- Dockerfile created
- docker-compose.yml configured
- Local testing successful
- Image ready for Docker Hub

### Part 3: Minikube Deployment [COMPLETE]
- Minikube cluster running
- MongoDB and Flask deployments created
- Services exposed correctly
- PersistentVolume configured

### Part 5: ReplicaSets [COMPLETE]
- 3 replicas configured
- Auto-recovery tested and verified
- Scaling tested (2, 3, 5 replicas)
- All tests passing

## Test Results

Latest test run: **28/28 tests passed (100%)**

```
✓ Prerequisites Check (4/4)
✓ Kubernetes Resources (7/7)
✓ Pod Health Check (3/3)
✓ Todo App Functionality (8/8)
✓ ReplicaSet Auto-Recovery (1/1)
✓ Scaling Tests (3/3)
✓ Resource Configuration (2/2)
```

## Troubleshooting

### Port 5000 Already in Use
On macOS, port 5000 is used by Control Center. The docker-compose.yml uses port 5001 instead.

### ImagePullBackOff in Minikube
The deployment uses local images with `imagePullPolicy: Never`. Ensure the image is loaded:
```bash
minikube image load flask-todo-app:latest
```

### Pods Not Starting
Check logs:
```bash
kubectl logs <pod-name>
kubectl describe pod <pod-name>
```

## Contributing

This is an academic assignment. For questions or issues, please contact the team members.

## License

Academic project for Cloud Computing course (Fall 2025).


