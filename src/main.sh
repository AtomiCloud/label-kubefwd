#!/usr/bin/env bash

filepath="$1"

set -euo pipefail

[ "$filepath" = '' ] && echo "❌ 'Filepath' param not set" && exit 1

cat "$filepath" >>/dev/null || (echo "⚠️ File '$filepath' not found" && exit 1)

while true; do
  # get list of servcies with `kubefwd=true` label
  echo "🔎 Looking up services with 'kubefwd=true' annotations..."
  services_with_kubefwd="$(kubectl get services -o=jsonpath='{.items[?(@.metadata.annotations.kubefwd=="true")].metadata.name}')"

  # Iterate through the list of services and add the "kubefwd=true" label to each of them
  echo "🏷️ Labeling services with 'kubefwd=true' annotations..."
  # shellcheck disable=SC2068
  for service in ${services_with_kubefwd[@]}; do
    kubectl label svc "$service" kubefwd=true
  done

  services=$(yq eval -o=j '.services' "$filepath")
  for service in $(echo "$services" | jq -cr '.[]'); do
    echo "🏷️ Labeling service '$service' with 'kubefwd=true'..."
    kubectl label svc "$service" kubefwd=true || true
  done
  sleep 1
done
