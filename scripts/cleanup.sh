#!/usr/bin/env bash
set -euo pipefail

kubectl delete namespace ai-gateway --ignore-not-found=true --wait=true
echo 'AI gateway resources removed.'
