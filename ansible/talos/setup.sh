#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status
set -o pipefail  # Prevent errors in a pipeline from being masked
set -u  # Treat unset variables as an error

# Variables
TALOS_VERSION="1.9.4"
KUBERNETES_VERSION="1.32.2"
FLUX_GIT_REPO="https://github.com/benjaminmnoer/iac"
CLUSTER_NAME="talos-cluster"
KUBECONFIG_PATH="$HOME/.kube/config"
CILIUM_VERSION="1.17.1"

export GITHUB_USER=benjaminmnoer

echo "Setting up Talos Kubernetes cluster on Manjaro..."

# Step 2: Create Talos Cluster
echo "Creating local Talos cluster..."
# The below command cannot be used currently, since DNS seems to not work
# talosctl cluster create --name "$CLUSTER_NAME" --kubernetes-version "$KUBERNETES_VERSION" --workers=3
talosctl cluster create --name "$CLUSTER_NAME" --kubernetes-version "$KUBERNETES_VERSION" --workers=3 --config-patch @patch.yaml --skip-k8s-node-readiness-check

# echo "Removing CoreDNS..."
# kubectl delete deployment -n kube-system coredns || true

# Step 5: Install Cilium (CNI + DNS)
echo "Installing Cilium..."
# cilium-cli install --version "$CILIUM_VERSION" --set kubeProxyReplacement=true --set hubble.enabled=true --set dnsProxy.enable=true
# echo "Deploying Cilium to cluster"
helm install cilium cilium/cilium \
  --namespace kube-system \
  --set=ipam.mode=kubernetes \
  --set=kubeProxyReplacement=true \
  --set=securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
  --set=securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
  --set=cgroup.autoMount.enabled=false \
  --set=cgroup.hostRoot=/sys/fs/cgroup \
  --set=k8sServiceHost=localhost \
  --set=k8sServicePort=7445

# Wait for Cilium to be ready
echo "Waiting for Cilium to be ready..."
cilium-cli status --wait

# Step 6: Verify Cilium DNS
echo "Testing DNS resolution..."
kubectl run -it --rm --restart=Never --image=busybox dns-test -- nslookup google.com
# Step 3: Configure Kubectl
# echo "Configuring kubectl context..."
# mkdir -p ~/.kube
# talosctl kubeconfig --name "$CLUSTER_NAME" > "$KUBECONFIG_PATH"
# export KUBECONFIG="$KUBECONFIG_PATH"
sleep 60
echo "Talos cluster is ready!"

# Step 4: Install Flux CD
# echo "Installing Flux CD..."
# curl -s https://fluxcd.io/install.sh | sudo bash
flux --version
flux check --pre

# Step 5: Bootstrap Flux
echo "Bootstrapping Flux into the Talos cluster..."
flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository="iac" \
  --branch="master" \
  --path="clusters/staging/flux" \
  --personal

echo "Talos Kubernetes Cluster with Flux CD is successfully set up!"
