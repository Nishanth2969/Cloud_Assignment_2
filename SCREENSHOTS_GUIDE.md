# Screenshots Documentation Guide

This guide explains what screenshots to capture for the assignment documentation.

## Part 2: Docker Compose Screenshots

### Screenshot 1: Docker Images Built
**Command:**
```bash
docker images | grep flask-todo-app
```
**What to show:** Docker image with tag and size

### Screenshot 2: Docker Compose Running
**Command:**
```bash
docker-compose ps
docker ps
```
**What to show:** Both Flask and MongoDB containers running with status "Up"

### Screenshot 3: Application Running Locally
**Browser:**
- URL: http://localhost:5000
- Show homepage with navigation menu
- Show at least 2-3 tasks created

### Screenshot 4: Docker Compose Logs
**Command:**
```bash
docker-compose logs flask-app
```
**What to show:** Application startup logs showing Flask running

### Screenshot 5: Creating a Task
**Browser:**
- Show the form for creating a task
- Filled in with sample data

### Screenshot 6: Task List Views
**Browser:**
- Show "All Tasks" view
- Show "Completed" view
- Show "Uncompleted" view

### Screenshot 7: Docker Hub Push
**Command:**
```bash
docker images
```
**Browser:**
- Docker Hub repository page showing the pushed image

## Part 3: Minikube Deployment Screenshots

### Screenshot 8: Minikube Status
**Command:**
```bash
minikube status
minikube version
```
**What to show:** Minikube running with all components

### Screenshot 9: Kubernetes Resources
**Command:**
```bash
kubectl get all
```
**What to show:** All deployments, pods, services, and replicasets

### Screenshot 10: Pods Running
**Command:**
```bash
kubectl get pods -o wide
```
**What to show:** All pods (Flask + MongoDB) in Running state

### Screenshot 11: ReplicaSets
**Command:**
```bash
kubectl get rs
kubectl describe rs <replicaset-name>
```
**What to show:** ReplicaSet with 3/3 replicas ready

### Screenshot 12: Services
**Command:**
```bash
kubectl get svc
minikube service list
```
**What to show:** Flask service with NodePort and MongoDB service

### Screenshot 13: Application on Minikube
**Browser:**
- Minikube service URL
- Application homepage
- Tasks created on Minikube

### Screenshot 14: Persistent Volume
**Command:**
```bash
kubectl get pv
kubectl get pvc
```
**What to show:** MongoDB persistent volume claim bound

## Part 5: ReplicaSet Testing Screenshots

### Screenshot 15: Initial Pod State
**Command:**
```bash
kubectl get pods -l app=flask-todo-app
```
**What to show:** 3 pods running initially

### Screenshot 16: Deleting a Pod
**Command:**
```bash
kubectl delete pod <pod-name>
kubectl get pods -l app=flask-todo-app
```
**What to show:** One pod terminating

### Screenshot 17: Auto-Recovery in Progress
**Command:**
```bash
kubectl get pods -l app=flask-todo-app -w
```
**What to show:** New pod being created (ContainerCreating status)

### Screenshot 18: Recovery Complete
**Command:**
```bash
kubectl get pods -l app=flask-todo-app
```
**What to show:** 3 pods running again (new pod with different name)

### Screenshot 19: ReplicaSet Events
**Command:**
```bash
kubectl describe rs <replicaset-name>
```
**What to show:** Events section showing pod deletion and creation

### Screenshot 20: Scaling to 5 Replicas
**Command:**
```bash
kubectl scale deployment flask-todo-app --replicas=5
kubectl get pods -l app=flask-todo-app
```
**What to show:** 5 pods running

### Screenshot 21: ReplicaSet After Scale Up
**Command:**
```bash
kubectl get rs
kubectl describe deployment flask-todo-app
```
**What to show:** ReplicaSet showing 5/5 replicas

### Screenshot 22: Scaling Down to 2 Replicas
**Command:**
```bash
kubectl scale deployment flask-todo-app --replicas=2
kubectl get pods -l app=flask-todo-app
```
**What to show:** Only 2 pods running

### Screenshot 23: Final Scale to 3 Replicas
**Command:**
```bash
kubectl scale deployment flask-todo-app --replicas=3
kubectl get pods -l app=flask-todo-app
kubectl get rs
```
**What to show:** Back to 3 pods

### Screenshot 24: Deployment Details
**Command:**
```bash
kubectl describe deployment flask-todo-app
```
**What to show:** Deployment configuration with replicas, scaling history

## Optional Screenshots (Bonus Points)

### Screenshot 25: Kubernetes Dashboard
**Command:**
```bash
minikube dashboard
```
**What to show:** Kubernetes dashboard showing all resources

### Screenshot 26: Pod Logs
**Command:**
```bash
kubectl logs <pod-name>
```
**What to show:** Flask application logs from a pod

### Screenshot 27: Pod Resource Usage
**Command:**
```bash
kubectl top pods
```
**What to show:** CPU and memory usage of pods

### Screenshot 28: MongoDB Connection Test
**Command:**
```bash
kubectl exec -it <flask-pod-name> -- env | grep MONGO
```
**What to show:** Environment variables configured correctly

## Screenshot Organization Tips

1. **Naming Convention:**
   - Use descriptive names: `01-docker-compose-running.png`
   - Include part number: `part2-docker-build.png`
   - Date if multiple attempts: `2025-10-28-minikube-pods.png`

2. **Quality:**
   - Use high resolution
   - Ensure terminal text is readable
   - Crop unnecessary parts
   - Highlight important sections if needed

3. **Context:**
   - Include command prompt showing current directory
   - Show timestamps when relevant
   - Capture full terminal output for commands

4. **Documentation:**
   - Create a folder: `screenshots/`
   - Separate by parts: `screenshots/part2/`, `screenshots/part3/`, etc.
   - Include captions in a separate document

## Creating Screenshot Document

Create a Word/PDF document with:

1. **Title Page**
   - Assignment title
   - Your name
   - Date
   - Course information

2. **For Each Screenshot:**
   - Screenshot title
   - Command used (if applicable)
   - Screenshot image
   - Brief explanation (2-3 sentences)
   - Timestamp/date

3. **Organization:**
   - Group by assignment parts
   - Number all screenshots
   - Cross-reference with command list

## Example Screenshot Caption Format

```
Screenshot 15: Initial Pod State Before Deletion
Command: kubectl get pods -l app=flask-todo-app
Date: October 28, 2025
Description: Shows 3 Flask application pods running before testing 
the ReplicaSet auto-recovery feature. All pods are in Running state 
with different ages.
```

