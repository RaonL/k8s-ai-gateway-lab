#!/usr/bin/env bash
set -euo pipefail

GATEWAY_URL="${GATEWAY_URL:-http://ai.lab.local}"
MODEL="${MODEL:-meta/llama-3.1-8b-instruct}"
REQUESTS="${REQUESTS:-3}"

for command in curl; do
  command -v "$command" >/dev/null || { echo "Required command not found: $command" >&2; exit 1; }
done

echo "Testing ${REQUESTS} request(s) against ${GATEWAY_URL}/v1/chat/completions"
for ((request=1; request<=REQUESTS; request++)); do
  echo "--- request ${request} ---"
  curl --fail-with-body --silent --show-error --include \
    -H 'Content-Type: application/json' \
    --data "{\"model\":\"${MODEL}\",\"messages\":[{\"role\":\"user\",\"content\":\"Reply with the node routing headers if visible.\"}],\"max_tokens\":32}" \
    "${GATEWAY_URL}/v1/chat/completions"
  echo
done
