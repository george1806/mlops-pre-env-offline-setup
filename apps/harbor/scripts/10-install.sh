#!/bin/bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAMESPACE="harbor"
CHART_NAME="harbor"
CHART_DIR="$APP_DIR/charts/harbor"
VALUES_TEMPLATE="$APP_DIR/values/harbor-values.yaml"
VALUES_RENDERED="$APP_DIR/values/harbor-values.rendered.yaml"
ENV_FILE="$APP_DIR/.env.local"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "❌ Missing $ENV_FILE"
  exit 1
fi

# Load env vars
set -a
source "$ENV_FILE"
set +a

# Render values file
echo "🔹 Preparing values file..."
sed \
  -e "s|__HARBOR_ADMIN_PASSWORD__|${HARBOR_ADMIN_PASSWORD}|g" \
  -e "s|__HARBOR_EXTERNAL_URL__|${HARBOR_EXTERNAL_URL}|g" \
  "$VALUES_TEMPLATE" > "$VALUES_RENDERED"

echo "🔹 Creating namespace: $NAMESPACE"
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

echo "🔹 Installing Harbor via Helm..."
helm upgrade --install "$CHART_NAME" "$CHART_DIR" \
  --namespace "$NAMESPACE" \
  -f "$VALUES_RENDERED"

echo "✅ Harbor install initiated. Check with:"
echo "   kubectl get pods -n $NAMESPACE -w"
