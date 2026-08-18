# K3s AI Gateway Lab

Three lightweight NGINX proxy pods distribute NVIDIA-hosted inference requests across the K3s nodes `yw` (`192.168.137.70`), `worker1` (`.71`), and `worker2` (`.72`). Kubernetes Service load balancing chooses a ready proxy pod; each proxy adds the NVIDIA API key server-side and forwards OpenAI-compatible `/v1/*` traffic to NVIDIA's Integrate endpoint.

The deployment uses required pod anti-affinity on `kubernetes.io/hostname`: three replicas therefore occupy three different schedulable nodes. If any node is unavailable, Kubernetes intentionally leaves the extra pod Pending rather than colocating it.

## Prerequisites

- `kubectl` configured for the K3s cluster, with all three nodes schedulable.
- NGINX Ingress Controller installed with class name `nginx`. K3s ships Traefik by default; install ingress-nginx separately or adapt `04-ingress.yaml` for Traefik.
- `envsubst` (usually from the `gettext` package), `make`, Bash, and `curl` on the admin host.
- An NVIDIA API key with access to the selected model.

The response-header annotations use `configuration-snippet`. If ingress-nginx disables snippets, enable `allow-snippet-annotations` in its controller configuration or remove those two header lines; routing and rate limiting do not depend on them.

## Deploy

Never commit the API key. Load it only into your shell:

```bash
export NVIDIA_API_KEY='your-nvidia-api-key'
make deploy
kubectl get pods -n ai-gateway -o wide
```

Confirm that the three Ready pods show one pod on each of `yw`, `worker1`, and `worker2`. The Secret template is rendered in memory by `scripts/deploy.sh`; it is not applied with an unresolved placeholder.

Point `ai.lab.local` at an ingress-controller address (or use your controller NodePort, such as `32100`):

```bash
export GATEWAY_URL='http://ai.lab.local'
make test
```

Choose another NVIDIA model without changing manifests:

```bash
MODEL='mistralai/mistral-7b-instruct-v0.3' make test
```

`make test` sends real inference requests and may consume API quota. It prints response headers including `X-LB-Node` when snippets are enabled.

## Operations

```bash
make status
make clean
```

`make clean` deletes only the `ai-gateway` namespace and all resources contained in it.
