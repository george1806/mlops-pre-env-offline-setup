#!/usr/bin/env bash
set -euo pipefail

echo "🔹 Stopping k3s service..."
if systemctl is-active --quiet k3s; then
  sudo systemctl stop k3s
fi

echo "🔹 Running official uninstall script (if exists)..."
if [ -f /usr/local/bin/k3s-uninstall.sh ]; then
  sudo /usr/local/bin/k3s-uninstall.sh
fi
if [ -f /usr/local/bin/k3s-agent-uninstall.sh ]; then
  sudo /usr/local/bin/k3s-agent-uninstall.sh
fi

echo "🔹 Removing leftover directories..."
sudo rm -rf \
  /etc/rancher \
  /var/lib/rancher \
  /var/lib/kubelet \
  /var/lib/cni \
  /run/k3s \
  /var/lib/rancher-data

echo "🔹 Removing binaries..."
sudo rm -f /usr/local/bin/k3s
sudo rm -f /usr/local/bin/kubectl
sudo rm -f /usr/local/bin/crictl
sudo rm -f /usr/local/bin/ctr

echo "🔹 Removing systemd unit files..."
sudo rm -f /etc/systemd/system/k3s.service
sudo rm -f /etc/systemd/system/k3s-agent.service
sudo systemctl daemon-reload

echo "🔹 Cleaning up kube config..."
rm -rf ~/.kube

echo "✅ K3s and related settings have been fully removed."
