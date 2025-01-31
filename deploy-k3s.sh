#!/bin/bash

# TODO: ask for the domain name

# install k3s without traefik
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --disable traefik" sh

# configure tls san to allow outside connections to the cluster
sudo mkdir -p /etc/rancher/k3s && sudo tee /etc/rancher/k3s/config.yaml > /dev/null <<EOF
write-kubeconfig-mode: "0644"
tls-san:
  - "gepnir.ovh"
cluster-init: true
EOF

# copy kube config: https://devops.stackexchange.com/a/16044
export KUBECONFIG="$HOME/.kube/config"
mkdir "$HOME/.kube" 2> /dev/null
sudo k3s kubectl config view --raw > "$KUBECONFIG"
chmod 600 "$KUBECONFIG"

# fix storage path provider: https://github.com/k3s-io/k3s/issues/85#issuecomment-492475034
sudo mkdir /opt/local-path-provisioner
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
