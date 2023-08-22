#!/usr/bin/env bash

filepath="$1"

set -euo pipefail

[ "$filepath" = '' ] && echo "❌ 'Filepath' param not set" && exit 1

cat "$filepath" >>/dev/null || (echo "⚠️ File '$filepath' not found" && exit 1)

delay="$(yq eval -o=j '.interval' "$filepath")"
defer="$(yq eval -o=j '.defer' "$filepath")"

while true; do
  # get list of servcies with `kubefwd=true` label
  echo "🔎 Looking up services with 'kubefwd=true' annotations..."
  services_with_kubefwd="$(kubectl get svc -o json | jq -r '.items[] | select((.metadata.annotations."kubefwd" == "true") and (.metadata.labels == null or .metadata.labels."kubefwd" != "true")) | .metadata.name')"

  # Iterate through the list of services and add the "kubefwd=true" label to each of them
  echo "🏷️ Labeling services with 'kubefwd=true' annotations..."
  # shellcheck disable=SC2068
  for service in ${services_with_kubefwd[@]}; do
    # check if service is ready
    echo "🔎 Checking if service '$service' is ready..."
    ready="$(./src/check_service.sh "$service" || echo "false")"
    if [ "$ready" = 'true' ]; then
      # check if there is kubefwd/defer annotation
      echo "🔎 Checking if service '$service' has 'kubefwd/defer' annotation..."
      defer_annotation="$(kubectl get svc "$service" -o json | jq -r '.metadata.annotations."kubefwd/defer"')"
      if [ "$defer_annotation" = 'null' ]; then
        defer_annotation="$defer"
      fi
      # defer the labeling based on annotation value
      echo "🕛 Defer service '$service' labeling for '$defer_annotation' seconds..."
      sleep "$defer_annotation"
      echo "🏷️ Labeling service '$service' with 'kubefwd=true'..."
      kubectl label svc "$service" kubefwd=true
    else
      # skip labelling since not ready
      echo "⚠️ Service '$service' is not ready, skipping..."
    fi
  done

  services=$(yq eval -o=j '.services' "$filepath")
  for service in $(echo "$services" | jq -cr '.[]'); do
    echo "🔎 Checking if service '$service' has 'kubefwd=true' label..."
    has_kubefwd_label="$(kubectl get svc "$service" -o json | jq -r '.metadata.labels."kubefwd"')"
    if [ "$has_kubefwd_label" = 'true' ]; then
      continue # skip since already labeled
    fi
    echo "🔎 Checking if service '$service' is ready..."
    ready="$(./src/check_service.sh "$service" || echo "false")"
    if [ "$ready" = 'true' ]; then

      # check if there is kubefwd/defer annotation
      echo "🔎 Checking if service '$service' has 'kubefwd/defer' annotation..."
      defer_annotation="$(kubectl get svc "$service" -o json | jq -r '.metadata.annotations."kubefwd/defer"')"
      if [ "$defer_annotation" = 'null' ]; then
        defer_annotation="$defer"
      fi
      # defer the labeling based on annotation value
      echo "🕛 Defer service '$service' labeling for '$defer_annotation' seconds..."
      sleep "$defer_annotation"

      echo "🏷️ Labeling service '$service' with 'kubefwd=true'..."
      kubectl label svc "$service" kubefwd=true || true
    else
      # skip labelling since not ready
      echo "⚠️ Service '$service' is not ready, skipping..."
    fi
  done
  sleep "$delay"
done
