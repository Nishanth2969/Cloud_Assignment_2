#!/bin/bash

# Script to update Docker Hub username in Kubernetes deployment files

if [ -z "$1" ]; then
    echo "Usage: ./update-dockerhub-username.sh <your-dockerhub-username>"
    exit 1
fi

DOCKERHUB_USERNAME=$1

echo "Updating k8s/flask-deployment-eks.yaml with Docker Hub username: $DOCKERHUB_USERNAME"

# Backup the original file
cp k8s/flask-deployment-eks.yaml k8s/flask-deployment-eks.yaml.backup

# Update the username
sed -i '' "s/your-dockerhub-username/${DOCKERHUB_USERNAME}/g" k8s/flask-deployment-eks.yaml

echo "Updated successfully!"
echo ""
echo "Review the changes:"
grep "image:" k8s/flask-deployment-eks.yaml

