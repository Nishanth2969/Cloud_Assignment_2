#!/bin/bash

# Validation script for project setup
# This validates all files and configurations without requiring Docker to be running

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "=========================================="
echo "Project Setup Validation"
echo "=========================================="
echo ""

PASS_COUNT=0
FAIL_COUNT=0

check_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASS_COUNT++))
}

check_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAIL_COUNT++))
}

check_warn() {
    echo -e "${YELLOW}!${NC} $1"
}

# 1. Check Required Tools
echo "1. Checking Required Tools..."
echo "----------------------------"

if command -v docker &> /dev/null; then
    check_pass "Docker installed: $(docker --version 2>&1 | head -n1)"
    
    if docker ps &> /dev/null; then
        check_pass "Docker daemon is running"
    else
        check_warn "Docker daemon is not running - start Docker Desktop"
    fi
else
    check_fail "Docker not installed"
fi

if command -v docker-compose &> /dev/null; then
    check_pass "Docker Compose installed: $(docker-compose --version)"
else
    check_fail "Docker Compose not installed"
fi

if command -v minikube &> /dev/null; then
    check_pass "Minikube installed: $(minikube version --short 2>&1)"
else
    check_fail "Minikube not installed"
fi

if command -v kubectl &> /dev/null; then
    check_pass "kubectl installed"
else
    check_fail "kubectl not installed"
fi

echo ""

# 2. Check Project Structure
echo "2. Checking Project Files..."
echo "----------------------------"

# Core application files
[ -f "app.py" ] && check_pass "app.py exists" || check_fail "app.py missing"
[ -f "requirements.txt" ] && check_pass "requirements.txt exists" || check_fail "requirements.txt missing"
[ -d "templates" ] && check_pass "templates/ directory exists" || check_fail "templates/ missing"
[ -d "static" ] && check_pass "static/ directory exists" || check_fail "static/ missing"

# Docker files
[ -f "Dockerfile" ] && check_pass "Dockerfile exists" || check_fail "Dockerfile missing"
[ -f "docker-compose.yml" ] && check_pass "docker-compose.yml exists" || check_fail "docker-compose.yml missing"
[ -f ".dockerignore" ] && check_pass ".dockerignore exists" || check_fail ".dockerignore missing"

# Kubernetes files
[ -d "k8s" ] && check_pass "k8s/ directory exists" || check_fail "k8s/ missing"
[ -f "k8s/mongodb-deployment-eks.yaml" ] && check_pass "MongoDB EKS deployment exists" || check_fail "MongoDB EKS deployment missing"
[ -f "k8s/mongodb-service.yaml" ] && check_pass "MongoDB service exists" || check_fail "MongoDB service missing"
[ -f "k8s/flask-deployment-eks.yaml" ] && check_pass "Flask EKS deployment exists" || check_fail "Flask EKS deployment missing"
[ -f "k8s/flask-service.yaml" ] && check_pass "Flask service exists" || check_fail "Flask service missing"

echo ""

# 3. Check Automation Scripts
echo "3. Checking Automation Scripts..."
echo "----------------------------"

scripts=(
    "build-and-push.sh"
    "update-dockerhub-username.sh"
    "deploy-minikube.sh"
    "test-all.sh"
    "validate-setup.sh"
)

for script in "${scripts[@]}"; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            check_pass "$script (executable)"
        else
            check_warn "$script exists but not executable"
        fi
    else
        check_fail "$script missing"
    fi
done

echo ""

# 4. Check Documentation
echo "4. Checking Documentation..."
echo "----------------------------"

if [ -f "README.md" ]; then
    lines=$(wc -l < "README.md" | tr -d ' ')
    check_pass "README.md ($lines lines)"
else
    check_fail "README.md missing"
fi

if [ -f "Cloud Documentation.pdf" ]; then
    check_pass "Cloud Documentation.pdf exists"
else
    check_warn "Cloud Documentation.pdf not found"
fi

if [ -f "Cloud Documentation.docx" ]; then
    check_pass "Cloud Documentation.docx exists"
else
    check_warn "Cloud Documentation.docx not found"
fi

echo ""

# 5. Validate YAML Syntax
echo "5. Validating YAML Syntax..."
echo "----------------------------"

if command -v python3 &> /dev/null; then
    for yaml in k8s/*.yaml; do
        if python3 -c "import yaml; yaml.safe_load_all(open('$yaml'))" &> /dev/null; then
            check_pass "$(basename $yaml) - valid syntax"
        else
            check_fail "$(basename $yaml) - invalid syntax"
        fi
    done
else
    check_warn "Python not available - skipping YAML validation"
fi

echo ""

# 6. Check Docker Compose Syntax
echo "6. Validating Docker Compose..."
echo "----------------------------"

if command -v docker-compose &> /dev/null && [ -f "docker-compose.yml" ]; then
    if docker-compose config &> /dev/null; then
        check_pass "docker-compose.yml - valid syntax"
    else
        check_fail "docker-compose.yml - invalid syntax"
    fi
else
    check_warn "docker-compose not available or file missing"
fi

echo ""

# 7. Check Templates
echo "7. Checking HTML Templates..."
echo "----------------------------"

templates=(
    "templates/index.html"
    "templates/searchlist.html"
    "templates/update.html"
    "templates/credits.html"
)

for template in "${templates[@]}"; do
    [ -f "$template" ] && check_pass "$(basename $template) exists" || check_fail "$(basename $template) missing"
done

echo ""

# 8. Check Static Assets
echo "8. Checking Static Assets..."
echo "----------------------------"

[ -d "static/assets" ] && check_pass "static/assets/ exists" || check_fail "static/assets/ missing"
[ -d "static/images" ] && check_pass "static/images/ exists" || check_fail "static/images/ missing"

if [ -d "static/assets" ]; then
    asset_count=$(find static/assets -type f | wc -l | tr -d ' ')
    check_pass "$asset_count files in static/assets/"
fi

if [ -d "static/images" ]; then
    image_count=$(find static/images -type f | wc -l | tr -d ' ')
    check_pass "$image_count files in static/images/"
fi

echo ""

# Summary
echo "=========================================="
echo "Validation Summary"
echo "=========================================="
echo -e "${GREEN}Passed: $PASS_COUNT${NC}"
echo -e "${RED}Failed: $FAIL_COUNT${NC}"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}All validations passed!${NC}"
    echo ""
    echo "Next Steps:"
    echo "1. Start Docker Desktop if not running"
    echo "2. Run: docker-compose up -d (to test locally)"
    echo "3. Run: minikube start --driver=docker"
    echo "4. Run: ./integration-tests.sh (to test on Minikube)"
    exit 0
else
    echo -e "${RED}Some validations failed${NC}"
    echo "Please fix the issues above before proceeding."
    exit 1
fi

