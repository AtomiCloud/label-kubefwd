#!/usr/bin/env bash

filepath="$1"

set -euo pipefail

[ "$filepath" = '' ] && echo "❌ 'Filepath' param not set" && exit 1

cat "$filepath" >>/dev/null || (echo "⚠️ File '$filepath' not found" && exit 1)

delay="$(yq eval -o=j '.interval' "$filepath")"

while true; do
  # get list of servcies with `kubefwd=true` label
  echo "🔎 Looking up services with 'kubefwd=true' annotations..."
  services_with_kubefwd="$(kubectl get services -o=jsonpath='{.items[?(@.metadata.annotations.kubefwd=="true")].metadata.name}')"

  # Iterate through the list of services and add the "kubefwd=true" label to each of them
  echo "🏷️ Labeling services with 'kubefwd=true' annotations..."
  # shellcheck disable=SC2068
  for service in ${services_with_kubefwd[@]}; do
    # check if service is ready
    echo "🔎 Checking if service '$service' is ready..."
    ready="$(/app/check_service.sh "$service" || echo "false")"
    if [ "$ready" = 'true' ]; then
      echo "🏷️ Labeling service '$service' with 'kubefwd=true'..."
      kubectl label svc "$service" kubefwd=true
    else
      # skip labelling since not ready
      echo "⚠️ Service '$service' is not ready, skipping..."
    fi
  done

  services=$(yq eval -o=j '.services' "$filepath")
  for service in $(echo "$services" | jq -cr '.[]'); do
    echo "🔎 Checking if service '$service' is ready..."
    ready="$(/app/check_service.sh "$service" || echo "false")"
    if [ "$ready" = 'true' ]; then
      echo "🏷️ Labeling service '$service' with 'kubefwd=true'..."
      kubectl label svc "$service" kubefwd=true || true
    else
      # skip labelling since not ready
      echo "⚠️ Service '$service' is not ready, skipping..."
    fi
  done
  sleep "$delay"
done
