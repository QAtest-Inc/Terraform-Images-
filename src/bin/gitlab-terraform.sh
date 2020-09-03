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

# If TF_USERNAME is unset then default to GITLAB_USER_LOGIN
if [ -z "${TF_USERNAME}" ]; then
  TF_USERNAME="${GITLAB_USER_LOGIN}"
fi

# If TF_PASSWORD is unset then default to gitlab-ci-token/CI_JOB_TOKEN
if [ -z "${TF_PASSWORD}" ]; then
  TF_USERNAME="gitlab-ci-token"
  TF_PASSWORD="${CI_JOB_TOKEN}"
fi

init() {
  terraform init \
    -backend-config="address=${TF_ADDRESS}" \
    -backend-config="lock_address=${TF_ADDRESS}/lock" \
    -backend-config="unlock_address=${TF_ADDRESS}/lock" \
    -backend-config="username=${TF_USERNAME}" \
    -backend-config="password=${TF_PASSWORD}" \
    -backend-config="lock_method=POST" \
    -backend-config="unlock_method=DELETE" \
    -backend-config="retry_wait_min=5" \
    -reconfigure
}

case "${1}" in
  "apply")
    init
    terraform "${@}" -input=false "${plan_cache}"
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
