#!/bin/bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$APP_DIR/.env.local"
IMAGES_FILE="$APP_DIR/images.json"
LOGS_DIR="$APP_DIR/logs"
LOG_FILE="$LOGS_DIR/push-report.log"

# Load env
function load_env() {
  if [[ ! -f "$ENV_FILE" ]]; then
    echo "❌ Missing $ENV_FILE"
    exit 1
  fi
  set -a
  source "$ENV_FILE"
  set +a
}

# Prepare logs dir
function init_logs() {
  mkdir -p "$LOGS_DIR"
  echo "📄 Push Report - $(date)" > "$LOG_FILE"
  echo "----------------------------------------" >> "$LOG_FILE"
}

# Login to Harbor
function login_harbor() {
  echo "🔹 Logging into Harbor..."
  echo "$HARBOR_ADMIN_PASSWORD" | docker login "$HARBOR_URL" -u "$HARBOR_USER" --password-stdin
}

# Process images
function process_images() {
  if [[ ! -f "$IMAGES_FILE" ]]; then
    echo "❌ Missing $IMAGES_FILE"
    exit 1
  fi

  IMAGES=$(jq -r '.[]' "$IMAGES_FILE")

  for SOURCE_IMAGE in $IMAGES; do
    IMAGE_NAME=$(echo "$SOURCE_IMAGE" | cut -d: -f1 | awk -F'/' '{print $NF}')
    IMAGE_TAG=$(echo "$SOURCE_IMAGE" | cut -d: -f2)
    TARGET_IMAGE="$HARBOR_URL/$HARBOR_PROJECT/$IMAGE_NAME:$IMAGE_TAG"

    echo "---------------------------------------------"
    echo "➡️  Processing: $SOURCE_IMAGE"
    echo "   Target: $TARGET_IMAGE"

    {
      docker pull "$SOURCE_IMAGE" &&
      docker tag "$SOURCE_IMAGE" "$TARGET_IMAGE" &&
      docker push "$TARGET_IMAGE"
    } && {
      echo "✅ SUCCESS: $SOURCE_IMAGE → $TARGET_IMAGE" | tee -a "$LOG_FILE"
    } || {
      echo "❌ FAILED: $SOURCE_IMAGE" | tee -a "$LOG_FILE"
    }
  done
}

# Main
function main() {
  load_env
  init_logs
  login_harbor
  process_images
  echo "🎉 All images processed. Report saved at $LOG_FILE"
}

main
