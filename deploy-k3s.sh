#!/bin/bash

read -p "Please input the domain of your cluster: " CLUSTER_DOMAIN

# install k3s without traefik
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --disable traefik" sh

# configure tls san to allow outside connections to the cluster
sudo mkdir -p /etc/rancher/k3s && sudo tee /etc/rancher/k3s/config.yaml > /dev/null <<EOF
write-kubeconfig-mode: "0644"
tls-san:
  - "${CLUSTER_DOMAIN}"
cluster-init: true
EOF

# NOTE: how to use the local storage provider: https://docs.k3s.io/storage#setting-up-the-local-storage-provider

# COPY kube config: https://devops.stackexchange.com/a/16044
export KUBECONFIG="$HOME/.kube/config"
mkdir "$HOME/.kube" 2> /dev/null
sudo k3s kubectl config view --raw > "$KUBECONFIG"
chmod 600 "$KUBECONFIG"
