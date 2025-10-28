#!/bin/bash

# Script to deploy the Flask Todo application on Minikube

echo "Checking Minikube status..."
minikube status

if [ $? -ne 0 ]; then
    echo "Starting Minikube..."
    minikube start --driver=docker
fi

echo "Deploying MongoDB..."
kubectl apply -f k8s/mongodb-deployment.yaml
kubectl apply -f k8s/mongodb-service.yaml

echo "Waiting for MongoDB to be ready..."
kubectl wait --for=condition=ready pod -l app=mongodb --timeout=120s

echo "Deploying Flask application..."
kubectl apply -f k8s/flask-deployment.yaml
kubectl apply -f k8s/flask-service.yaml

echo "Waiting for Flask pods to be ready..."
kubectl wait --for=condition=ready pod -l app=flask-todo-app --timeout=120s

echo "Deployment complete!"
echo ""
echo "Getting service URL..."
minikube service flask-todo-service --url
echo ""
echo "To open in browser, run:"
echo "minikube service flask-todo-service"

