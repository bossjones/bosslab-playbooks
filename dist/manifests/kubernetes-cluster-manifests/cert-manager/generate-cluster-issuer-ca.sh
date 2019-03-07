#!/usr/bin/env bash

# SOURCE: https://docs.cert-manager.io/en/latest/tasks/issuers/setup-ca.html

# Generate a CA private key
env PATH="/usr/local/opt/openssl/bin:$PATH" openssl genrsa -out /Users/malcolm/dev/bossjones/bosslab-playbooks/dist/manifests/kubernetes-cluster-manifests/cert-manager/ca.key 2048 && \
# Create a self signed Certificate, valid for 10yrs with the 'signing' option set
env PATH="/usr/local/opt/openssl/bin:$PATH" openssl req -x509 -new -nodes -key /Users/malcolm/dev/bossjones/bosslab-playbooks/dist/manifests/kubernetes-cluster-manifests/cert-manager/ca.key -subj "/CN=*.scarlettlab.com" -days 3650 -reqexts v3_req -extensions v3_ca -out /Users/malcolm/dev/bossjones/bosslab-playbooks/dist/manifests/kubernetes-cluster-manifests/cert-manager/ca.crt


# s:/C=US/ST=Texas/L=Carrollton/O=Woot Inc/CN=*.woot.com
# i:/C=US/O=SecureTrust Corporation/CN=SecureTrust CA

# SOURCE: https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/
cat <<EOF > /Users/malcolm/dev/bossjones/bosslab-playbooks/dist/manifests/kubernetes-cluster-manifests/cert-manager/my-cluster-ca-key-pair-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-cluster-ca-key-pair
  namespace: default
type: kubernetes.io/tls
data:
  tls.crt: $(/bin/cat /Users/malcolm/dev/bossjones/bosslab-playbooks/dist/manifests/kubernetes-cluster-manifests/cert-manager/ca.crt | base64 -w0)
  tls.key: $(/bin/cat /Users/malcolm/dev/bossjones/bosslab-playbooks/dist/manifests/kubernetes-cluster-manifests/cert-manager/ca.key | base64 -w0)
EOF
