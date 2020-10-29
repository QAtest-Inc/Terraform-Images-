#!/bin/sh -e

# Helpers
terraform_is_at_least() {
  [ "${1}" = "$(terraform -version | awk -v min="${1}" '/^Terraform v/{ sub(/^v/, "", $2); print min; print $2 }' | sort -V | head -n1)" ]
  return $?
}

set -x

plan_cache="plan.cache"
plan_json="plan.json"

JQ_PLAN='
  (
    [.resource_changes[]?.change.actions?] | flatten
  ) | {
    "create":(map(select(.=="create")) | length),
    "update":(map(select(.=="update")) | length),
    "delete":(map(select(.=="delete")) | length)
  }
'

apply() {
  if ! terraform_is_at_least 0.13.2; then
    tfplantool -f "${plan_cache}" backend set -k password -v "${TF_PASSWORD}"
  fi
  terraform "${@}" -input=false "${plan_cache}"
}

init() {
  if [ -n "${TF_HTTP_ADDRESS}" ] && ! terraform_is_at_least 0.13.2; then
    set -- \
      -backend-config=address="${TF_HTTP_ADDRESS}" \
      -backend-config=lock_address="${TF_HTTP_LOCK_ADDRESS}" \
      -backend-config=unlock_address="${TF_HTTP_UNLOCK_ADDRESS}" \
      -backend-config=username="${TF_HTTP_USERNAME}" \
      -backend-config=password="${TF_HTTP_PASSWORD}" \
      -backend-config=lock_method="${TF_HTTP_LOCK_METHOD}" \
      -backend-config=unlock_method="${TF_HTTP_UNLOCK_METHOD}" \
      -backend-config=retry_wait_min="${TF_HTTP_RETRY_WAIT_MIN}"
  fi
  terraform init "${@}" -reconfigure
}

case "${1}" in
  "apply")
    init
    apply "${@}"
  ;;
  "init")
    init
  ;;
  "plan")
    init
    terraform "${@}" -out="${plan_cache}"
  ;;
  "plan-json")
    terraform show -json "${plan_cache}" | \
      jq -r "${JQ_PLAN}" \
      > "${plan_json}"
  ;;
  *)
    terraform "${@}"
  ;;
esac
