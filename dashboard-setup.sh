cd /vagrant

# Get the latest git tag from GitHub tags API (more reliable than releases API)
# The tags API returns actual git tag names that work with raw.githubusercontent.com
VERSION_KUBE_DASHBOARD=$(curl -s https://api.github.com/repos/kubernetes/dashboard/tags 2>/dev/null | grep '"name":' | head -1 | sed -E 's/.*"([^"]+)".*/\1/')

# Verify the URL exists, fallback to known stable versions if not
DASHBOARD_URL=""
if [ -n "$VERSION_KUBE_DASHBOARD" ] && [ "$VERSION_KUBE_DASHBOARD" != "null" ]; then
  TEST_URL="https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml"
  if curl -s -o /dev/null -w "%{http_code}" "$TEST_URL" | grep -q "200"; then
    DASHBOARD_URL="$TEST_URL"
    echo "Using Kubernetes Dashboard version: ${VERSION_KUBE_DASHBOARD}"
  fi
fi

# Try fallback versions if auto-detection failed
if [ -z "$DASHBOARD_URL" ]; then
  for fallback_version in "v2.7.0" "v2.6.1" "v2.5.1"; do
    TEST_URL="https://raw.githubusercontent.com/kubernetes/dashboard/${fallback_version}/aio/deploy/recommended.yaml"
    if curl -s -o /dev/null -w "%{http_code}" "$TEST_URL" | grep -q "200"; then
      DASHBOARD_URL="$TEST_URL"
      VERSION_KUBE_DASHBOARD="$fallback_version"
      echo "Using fallback version: ${fallback_version}"
      break
    fi
  done
fi

# Exit if no valid URL found
if [ -z "$DASHBOARD_URL" ]; then
  echo "Error: Could not find a valid Kubernetes Dashboard deployment URL"
  exit 1
fi

# Deploy the dashboard (apply is idempotent, create is not)
echo "Deploying Kubernetes Dashboard from: ${DASHBOARD_URL}"
kubectl apply -f "$DASHBOARD_URL"

# Wait for namespace to be created
echo "Waiting for kubernetes-dashboard namespace..."
timeout=60
elapsed=0
while ! kubectl get namespace kubernetes-dashboard >/dev/null 2>&1; do
  if [ $elapsed -ge $timeout ]; then
    echo "Timeout waiting for namespace to be created"
    exit 1
  fi
  sleep 1
  elapsed=$((elapsed + 1))
done
echo "Namespace created"

# Wait for dashboard deployment to be ready
echo "Waiting for dashboard deployment to be ready..."
if kubectl wait --for=condition=available --timeout=300s deployment/kubernetes-dashboard -n kubernetes-dashboard 2>/dev/null; then
  echo "Dashboard deployment is ready"
else
  echo "Warning: Dashboard deployment may not be fully ready, but proceeding..."
fi

# Create admin user and role binding
echo "Creating admin user..."
kubectl apply -f dashboard.admin-user.yml -f dashboard.admin-user-role.yml

# Wait for service account to be ready
echo "Waiting for admin-user service account..."
timeout=30
elapsed=0
while ! kubectl get serviceaccount admin-user -n kubernetes-dashboard >/dev/null 2>&1; do
  if [ $elapsed -ge $timeout ]; then
    echo "Timeout waiting for service account to be created"
    exit 1
  fi
  sleep 1
  elapsed=$((elapsed + 1))
done
echo "Service account created"

# Get the admin user token
# Modern Kubernetes (1.24+) uses kubectl create token instead of auto-generated secrets
echo "Generating admin user token..."
TOKEN=""
if TOKEN=$(kubectl create token admin-user -n kubernetes-dashboard --duration=8760h 2>/dev/null); then
  echo "Admin user token:"
  echo "$TOKEN"
else
  # Fallback: Try to find an existing secret token (for older Kubernetes versions)
  echo "Attempting to retrieve token from existing secret..."
  SECRET_NAME=$(kubectl get secrets -n kubernetes-dashboard -o name 2>/dev/null | grep -E "(admin-user|admin-user-token)" | head -1)
  if [ -n "$SECRET_NAME" ]; then
    TOKEN=$(kubectl -n kubernetes-dashboard get "$SECRET_NAME" -o jsonpath='{.data.token}' 2>/dev/null | base64 -d 2>/dev/null)
    if [ -n "$TOKEN" ]; then
      echo "Admin user token:"
      echo "$TOKEN"
    else
      echo "Warning: Found secret but could not extract token"
    fi
  else
    echo "Warning: Could not retrieve token automatically."
    echo "You can generate it manually with:"
    echo "  kubectl create token admin-user -n kubernetes-dashboard"
  fi
fi
