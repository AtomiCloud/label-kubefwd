#!/usr/bin/env bash

SERVICE=$1

set -euo pipefail

# Fetch the label selector of the given service
selector=$(kubectl get svc "$SERVICE" -o jsonpath='{.spec.selector}' | tr -d '{}"' | tr ':' '=')

# If no selector, exit
if [ -z "$selector" ]; then
  echo "false"
  exit 0
fi

# Get the count of ready pods based on the selector
readyPods=$(kubectl get pods -l "$selector" -o jsonpath='{.items[?(@.status.phase=="Running")].status.containerStatuses[?(@.ready==true)].name}' | wc -w)

if [ "$readyPods" -gt 0 ]; then
  echo "true"
else
  echo "false"
fi
