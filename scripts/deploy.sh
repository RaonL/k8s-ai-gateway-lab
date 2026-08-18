#!/usr/bin/env bash
set -euo pipefail

for command in kubectl envsubst; do
  command -v "$command" >/dev/null || { echo "Required command not found: $command" >&2; exit 1; }
done

: "${NVIDIA_API_KEY:?Set NVIDIA_API_KEY before running make deploy.}"
if [[ "$NVIDIA_API_KEY" == "replace-with-your-nvidia-api-key" ]]; then
  echo "NVIDIA_API_KEY is still the example value." >&2
  exit 1
fi

echo '>>> [1/3] Creating namespace and NVIDIA API Secret'
kubectl apply -f manifests/00-namespace.yaml
envsubst '${NVIDIA_API_KEY}' < manifests/01-secret.yaml | kubectl apply -f -

echo '>>> [2/3] Deploying three distributed AI proxy replicas and Service'
kubectl apply -f manifests/02-proxy-deploy.yaml
kubectl apply -f manifests/03-service.yaml
kubectl rollout status deployment/ai-proxy-router -n ai-gateway --timeout=180s

echo '>>> [3/3] Applying NGINX Ingress routing and rate limit'
kubectl apply -f manifests/04-ingress.yaml
kubectl get pods -n ai-gateway -o wide
