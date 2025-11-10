#!/usr/bin/env bash
set -euo pipefail

### CONFIG
NODE_IP="192.168.0.21"         # adjust to your host's IP
K3S_VERSION="v1.28.8+k3s1"     # stable release
CONFIG_DIR="/etc/rancher/k3s"
USER_HOME="/home/$SUDO_USER"   # run with sudo so this picks the real user
KUBECONFIG_DEST="$USER_HOME/.kube/config"

### FUNCTIONS

check_prereqs() {
  echo "🔹 Checking prerequisites..."
  command -v curl >/dev/null || { echo "❌ curl missing"; exit 1; }
  command -v ip >/dev/null || { echo "❌ iproute2 missing"; exit 1; }
}

install_k3s() {
  echo "🔹 Installing K3s $K3S_VERSION..."AIRFLOW__KEYCLOAK_AUTH_MANAGER__SERVER_URL
  curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="$K3S_VERSION" sh -s - server --disable traefik --disable servicelb
}

configure_k3s() {
  echo "🔹 Configuring node IP $NODE_IP..."
  sudo mkdir -p "$CONFIG_DIR"
  cat <<EOF | sudo tee "$CONFIG_DIR/config.yaml"
node-ip: $NODE_IP
write-kubeconfig-mode: "644"

# Disable built-in components we want to manage ourselves
disable:
  - traefik

# Disable built-in components we want to manage ourselves
disable:
  - traefik
  - servicelb
EOF
}

setup_kubeconfig() {
  echo "🔹 Setting up kubeconfig for user $SUDO_USER..."
  mkdir -p "$USER_HOME/.kube"
  sudo cp /etc/rancher/k3s/k3s.yaml "$KUBECONFIG_DEST"
  sudo chown -R "$SUDO_USER":"$SUDO_USER" "$USER_HOME/.kube"
  # adjust server address if needed (defaults to 127.0.0.1)
  sed -i "s/127.0.0.1/$NODE_IP/" "$KUBECONFIG_DEST"
}

restart_k3s() {
  echo "🔹 Restarting K3s..."
  sudo systemctl daemon-reexec
  sudo systemctl restart k3s
  sleep 15
}

verify_install() {
  echo "🔹 Verifying K3s..."
  export KUBECONFIG="$KUBECONFIG_DEST"
  kubectl get nodes -o wide
}

### MAIN
check_prereqs
install_k3s
configure_k3s
restart_k3s
setup_kubeconfig
verify_install
