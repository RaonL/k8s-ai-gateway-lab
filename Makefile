SHELL := /usr/bin/env bash

.PHONY: deploy test clean status

deploy:
	@./scripts/deploy.sh

test:
	@./scripts/test-inference.sh

clean:
	@./scripts/cleanup.sh

status:
	@kubectl get pods,svc,ingress -n ai-gateway -o wide
