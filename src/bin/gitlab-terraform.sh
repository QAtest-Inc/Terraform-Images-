#!/bin/sh -e

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

case "${1}" in
  "apply")
    terraform "${@}" -input=false "${plan_cache}"
  ;;
  "init")
    terraform "${@}" \
      -backend-config="address=${TF_ADDRESS}" \
      -backend-config="lock_address=${TF_ADDRESS}/lock" \
      -backend-config="unlock_address=${TF_ADDRESS}/lock" \
      -backend-config="username=${GITLAB_USER_LOGIN}" \
      -backend-config="password=${GITLAB_TF_PASSWORD}" \
      -backend-config="lock_method=POST" \
      -backend-config="unlock_method=DELETE" \
      -backend-config="retry_wait_min=5"
  ;;
  "plan")
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
