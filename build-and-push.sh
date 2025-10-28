#!/bin/bash

# Script to build and push Docker image to Docker Hub
# Usage: ./build-and-push.sh <your-dockerhub-username>

if [ -z "$1" ]; then
    echo "Usage: ./build-and-push.sh <your-dockerhub-username>"
    exit 1
fi

DOCKERHUB_USERNAME=$1
IMAGE_NAME="flask-todo-app"
TAG="latest"

echo "Building Docker image..."
docker build -t ${IMAGE_NAME}:${TAG} .

if [ $? -ne 0 ]; then
    echo "Docker build failed!"
    exit 1
fi

echo "Tagging image for Docker Hub..."
docker tag ${IMAGE_NAME}:${TAG} ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${TAG}

echo "Logging into Docker Hub..."
docker login

if [ $? -ne 0 ]; then
    echo "Docker login failed!"
    exit 1
fi

echo "Pushing image to Docker Hub..."
docker push ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${TAG}

if [ $? -eq 0 ]; then
    echo "Successfully pushed ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${TAG}"
    echo ""
    echo "Next steps:"
    echo "1. Update k8s/flask-deployment.yaml with your Docker Hub username"
    echo "2. Run: sed -i '' 's/your-dockerhub-username/${DOCKERHUB_USERNAME}/g' k8s/flask-deployment.yaml"
else
    echo "Push failed!"
    exit 1
fi

