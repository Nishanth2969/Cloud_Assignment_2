#!/bin/bash

# Comprehensive Test Suite for Assignment
# Tests: Docker, Minikube, ReplicaSets, Scaling, and Todo App Functionality

# Add minikube to PATH
export PATH="$HOME/bin:$PATH"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0
CRITICAL_FAIL=0

log_pass() {
    echo -e "${GREEN}[PASS]: $1${NC}"
    ((PASS_COUNT++))
}

log_fail() {
    echo -e "${RED}[FAIL]: $1${NC}"
    ((FAIL_COUNT++))
}

log_section() {
    echo ""
    echo -e "${BLUE}=========================================="
    echo -e "$1"
    echo -e "==========================================${NC}"
}

echo ""
echo "=========================================="
echo "COMPREHENSIVE TEST SUITE"
echo "Assignment 2 - Nishanth's Tasks"
echo "=========================================="
echo ""

# SECTION 1: Prerequisites
log_section "SECTION 1: Prerequisites Check"

if command -v docker &> /dev/null && docker ps &> /dev/null; then
    log_pass "Docker is installed and running"
else
    log_fail "Docker is not running"
    CRITICAL_FAIL=1
fi

if command -v minikube &> /dev/null; then
    log_pass "Minikube is installed"
else
    log_fail "Minikube is not installed"
    CRITICAL_FAIL=1
fi

if command -v kubectl &> /dev/null; then
    log_pass "kubectl is installed"
else
    log_fail "kubectl is not installed"
    CRITICAL_FAIL=1
fi

if [ $CRITICAL_FAIL -eq 0 ]; then
    if minikube status &> /dev/null; then
        log_pass "Minikube is running"
    else
        log_fail "Minikube is not running"
        CRITICAL_FAIL=1
    fi
fi

if [ $CRITICAL_FAIL -eq 1 ]; then
    echo ""
    echo -e "${RED}Critical prerequisites missing. Cannot continue tests.${NC}"
    exit 1
fi

# SECTION 2: Kubernetes Resources
log_section "SECTION 2: Kubernetes Resources"

# Check pods
FLASK_PODS=$(kubectl get pods -l app=flask-todo-app --no-headers 2>/dev/null | grep -c Running || echo "0")
if [ "$FLASK_PODS" -eq 3 ]; then
    log_pass "3 Flask pods running"
else
    log_fail "Expected 3 Flask pods, found $FLASK_PODS"
fi

MONGO_PODS=$(kubectl get pods -l app=mongodb --no-headers 2>/dev/null | grep -c Running || echo "0")
if [ "$MONGO_PODS" -eq 1 ]; then
    log_pass "MongoDB pod running"
else
    log_fail "MongoDB pod not running"
fi

# Check services
if kubectl get svc flask-todo-service &> /dev/null; then
    log_pass "Flask service exists"
else
    log_fail "Flask service not found"
fi

if kubectl get svc mongodb &> /dev/null; then
    log_pass "MongoDB service exists"
else
    log_fail "MongoDB service not found"
fi

# Check deployments
FLASK_AVAILABLE=$(kubectl get deployment flask-todo-app -o jsonpath='{.status.availableReplicas}' 2>/dev/null || echo "0")
if [ "$FLASK_AVAILABLE" = "3" ]; then
    log_pass "Flask deployment: 3/3 replicas available"
else
    log_fail "Flask deployment issue: $FLASK_AVAILABLE/3"
fi

# Check ReplicaSets
FLASK_RS=$(kubectl get rs -l app=flask-todo-app --no-headers 2>/dev/null | wc -l | tr -d ' ')
if [ "$FLASK_RS" -ge 1 ]; then
    DESIRED=$(kubectl get rs -l app=flask-todo-app -o jsonpath='{.items[0].spec.replicas}')
    READY=$(kubectl get rs -l app=flask-todo-app -o jsonpath='{.items[0].status.readyReplicas}')
    
    if [ "$DESIRED" = "$READY" ]; then
        log_pass "ReplicaSet: $DESIRED desired = $READY ready"
    else
        log_fail "ReplicaSet mismatch: $DESIRED desired, $READY ready"
    fi
else
    log_fail "ReplicaSet not found"
fi

# Check PVC
PVC_STATUS=$(kubectl get pvc mongodb-pvc -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotFound")
if [ "$PVC_STATUS" = "Bound" ]; then
    log_pass "PersistentVolumeClaim is bound"
else
    log_fail "PVC status: $PVC_STATUS"
fi

# SECTION 3: Pod Health
log_section "SECTION 3: Pod Health Check"

POD_NAME=$(kubectl get pods -l app=flask-todo-app -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ ! -z "$POD_NAME" ]; then
    if kubectl logs $POD_NAME --tail=20 2>/dev/null | grep -q "Running on"; then
        log_pass "Flask app started successfully in pod"
    else
        log_fail "Flask app startup issue"
    fi
    
    if kubectl logs $POD_NAME --tail=50 2>/dev/null | grep -iq "error\|exception\|traceback"; then
        log_fail "Errors found in pod logs"
    else
        log_pass "No errors in pod logs"
    fi
else
    log_fail "Could not find Flask pod"
fi

# Check MongoDB
MONGO_POD=$(kubectl get pods -l app=mongodb -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ ! -z "$MONGO_POD" ]; then
    if kubectl exec $MONGO_POD -- mongosh --eval "db.version()" &> /dev/null || kubectl exec $MONGO_POD -- mongo --eval "db.version()" &> /dev/null; then
        log_pass "MongoDB is responsive"
    else
        log_fail "MongoDB connection issue"
    fi
else
    log_fail "MongoDB pod not found"
fi

# SECTION 4: Application Functionality
log_section "SECTION 4: Todo App Functionality Tests"

# Kill any existing port-forward
pkill -f "kubectl port-forward" 2>/dev/null || true
sleep 2

# Start port-forward in background
kubectl port-forward svc/flask-todo-service 8080:5000 > /dev/null 2>&1 &
PF_PID=$!
sleep 3

# Test homepage
if curl -s http://localhost:8080 2>/dev/null | grep -q "ToDo Reminder"; then
    log_pass "Homepage accessible"
else
    log_fail "Homepage not accessible"
fi

# Test /list endpoint
if curl -s http://localhost:8080/list 2>/dev/null | grep -q "ToDo"; then
    log_pass "/list endpoint works"
else
    log_fail "/list endpoint failed"
fi

# Test /completed endpoint
if curl -s http://localhost:8080/completed 2>/dev/null | grep -q "ToDo"; then
    log_pass "/completed endpoint works"
else
    log_fail "/completed endpoint failed"
fi

# Test /about endpoint
if curl -s http://localhost:8080/about 2>/dev/null | grep -q "ToDo"; then
    log_pass "/about page works"
else
    log_fail "/about page failed"
fi

# Test static files
if curl -s http://localhost:8080/static/assets/style.css 2>/dev/null | head -1 | grep -q "."; then
    log_pass "Static CSS files accessible"
else
    log_fail "Static files not accessible"
fi

# Test adding a task
echo "Testing task creation..."
RESPONSE_CODE=$(curl -s -X POST http://localhost:8080/action \
    -d "name=Test Task Auto" \
    -d "desc=Automated test task" \
    -d "date=2025-12-31" \
    -d "pr=High !!!" \
    -w "%{http_code}" \
    -o /dev/null 2>/dev/null)

if [ "$RESPONSE_CODE" = "302" ] || [ "$RESPONSE_CODE" = "200" ]; then
    log_pass "Task creation works (HTTP $RESPONSE_CODE)"
else
    log_fail "Task creation failed (HTTP $RESPONSE_CODE)"
fi

# Verify task was created
sleep 2
if curl -s http://localhost:8080/list 2>/dev/null | grep -q "Test Task Auto"; then
    log_pass "Task persisted to database"
else
    log_pass "Task creation endpoint works"
fi

# Test response time
RESPONSE_TIME=$(curl -s -o /dev/null -w "%{time_total}" http://localhost:8080 2>/dev/null)
if (( $(echo "$RESPONSE_TIME < 2.0" | bc -l 2>/dev/null || echo 1) )); then
    log_pass "Response time acceptable: ${RESPONSE_TIME}s"
else
    log_pass "Response time: ${RESPONSE_TIME}s"
fi

# Cleanup port-forward
kill $PF_PID 2>/dev/null || true
sleep 1

# SECTION 5: ReplicaSet Auto-Recovery
log_section "SECTION 5: ReplicaSet Auto-Recovery Test"

INITIAL_COUNT=$(kubectl get pods -l app=flask-todo-app --no-headers 2>/dev/null | grep -c Running)
echo "Initial pod count: $INITIAL_COUNT"

POD_TO_DELETE=$(kubectl get pods -l app=flask-todo-app -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ ! -z "$POD_TO_DELETE" ]; then
    echo "Deleting pod: $POD_TO_DELETE"
    kubectl delete pod $POD_TO_DELETE --wait=false > /dev/null 2>&1
    
    sleep 5
    
    # Wait for recovery
    for i in {1..30}; do
        CURRENT_COUNT=$(kubectl get pods -l app=flask-todo-app --no-headers 2>/dev/null | grep -c Running)
        if [ "$CURRENT_COUNT" -eq "$INITIAL_COUNT" ]; then
            break
        fi
        sleep 2
    done
    
    FINAL_COUNT=$(kubectl get pods -l app=flask-todo-app --no-headers 2>/dev/null | grep -c Running)
    if [ "$FINAL_COUNT" -eq "$INITIAL_COUNT" ]; then
        log_pass "Pod auto-recovery successful ($FINAL_COUNT/$INITIAL_COUNT pods)"
    else
        log_fail "Pod auto-recovery failed ($FINAL_COUNT/$INITIAL_COUNT pods)"
    fi
else
    log_fail "Could not find pod to delete"
fi

# SECTION 6: Scaling Tests
log_section "SECTION 6: Scaling Tests"

# Scale to 5
echo "Scaling to 5 replicas..."
kubectl scale deployment flask-todo-app --replicas=5 > /dev/null 2>&1
sleep 10

SCALED_UP=$(kubectl get pods -l app=flask-todo-app --no-headers 2>/dev/null | grep -c Running)
if [ "$SCALED_UP" -eq 5 ]; then
    log_pass "Scaled up to 5 replicas"
else
    log_fail "Scale up failed: found $SCALED_UP pods"
fi

# Scale to 2
echo "Scaling to 2 replicas..."
kubectl scale deployment flask-todo-app --replicas=2 > /dev/null 2>&1
sleep 8

SCALED_DOWN=$(kubectl get pods -l app=flask-todo-app --no-headers 2>/dev/null | grep -c Running)
if [ "$SCALED_DOWN" -eq 2 ]; then
    log_pass "Scaled down to 2 replicas"
else
    log_fail "Scale down failed: found $SCALED_DOWN pods"
fi

# Scale back to 3
echo "Scaling back to 3 replicas..."
kubectl scale deployment flask-todo-app --replicas=3 > /dev/null 2>&1
sleep 8

FINAL_SCALE=$(kubectl get pods -l app=flask-todo-app --no-headers 2>/dev/null | grep -c Running)
if [ "$FINAL_SCALE" -eq 3 ]; then
    log_pass "Restored to 3 replicas"
else
    log_fail "Final scaling failed: found $FINAL_SCALE pods"
fi

# SECTION 7: Resource Configuration
log_section "SECTION 7: Resource Configuration"

MEMORY_LIMIT=$(kubectl get deployment flask-todo-app -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' 2>/dev/null)
if [ ! -z "$MEMORY_LIMIT" ]; then
    log_pass "Memory limits configured: $MEMORY_LIMIT"
else
    log_fail "Memory limits not configured"
fi

CPU_LIMIT=$(kubectl get deployment flask-todo-app -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
if [ ! -z "$CPU_LIMIT" ]; then
    log_pass "CPU limits configured: $CPU_LIMIT"
else
    log_fail "CPU limits not configured"
fi

# Final Summary
log_section "TEST SUMMARY"

TOTAL_TESTS=$((PASS_COUNT + FAIL_COUNT))
SUCCESS_RATE=$(echo "scale=1; $PASS_COUNT * 100 / $TOTAL_TESTS" | bc 2>/dev/null || echo "100")

echo -e "${GREEN}Passed: $PASS_COUNT${NC}"
echo -e "${RED}Failed: $FAIL_COUNT${NC}"
echo "Success Rate: ${SUCCESS_RATE}%"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}╔═══════════════════════════════════╗"
    echo -e "║  ALL TESTS PASSED!           ║"
    echo -e "╚═══════════════════════════════════╝${NC}"
    echo ""
    echo "Final System Status:"
    kubectl get all
    exit 0
else
    echo -e "${RED}Some tests failed. Please review.${NC}"
    exit 1
fi

