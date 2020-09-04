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

# If TF_USERNAME is unset then default to GITLAB_USER_LOGIN
if [ -z "${TF_USERNAME}" ]; then
  TF_USERNAME="${GITLAB_USER_LOGIN}"
fi

# If TF_PASSWORD is unset then default to gitlab-ci-token/CI_JOB_TOKEN
if [ -z "${TF_PASSWORD}" ]; then
  TF_USERNAME="gitlab-ci-token"
  TF_PASSWORD="${CI_JOB_TOKEN}"
fi

# Export variables for the HTTP backend
export TF_HTTP_ADDRESS="${TF_ADDRESS}"
export TF_HTTP_LOCK_ADDRESS="${TF_ADDRESS}/lock"
export TF_HTTP_LOCK_METHOD="POST"
export TF_HTTP_UNLOCK_ADDRESS="${TF_ADDRESS}/lock"
export TF_HTTP_UNLOCK_METHOD="DELETE"
export TF_HTTP_USERNAME="${TF_USERNAME}"
export TF_HTTP_PASSWORD="${TF_PASSWORD}"
export TF_HTTP_RETRY_WAIT_MIN="5"

init() {
  if terraform_is_at_least 0.13.2; then
    terraform init -reconfigure
  else
    terraform init \
      -backend-config="address=${TF_HTTP_ADDRESS}" \
      -backend-config="lock_address=${TF_HTTP_LOCK_ADDRESS}" \
      -backend-config="unlock_address=${TF_HTTP_UNLOCK_ADDRESS}" \
      -backend-config="username=${TF_HTTP_USERNAME}" \
      -backend-config="password=${TF_HTTP_PASSWORD}" \
      -backend-config="lock_method=${TF_HTTP_LOCK_METHOD}" \
      -backend-config="unlock_method=${TF_HTTP_UNLOCK_METHOD}" \
      -backend-config="retry_wait_min=${TF_HTTP_RETRY_WAIT_MIN}" \
      -reconfigure
  fi
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
