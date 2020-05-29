#!/bin/sh -e

set -x

case "${1}" in
  "plan-json")
    output="${2}"
    shift 2
    terraform show --json "${@}" | jq -r '([.resource_changes[]?.change.actions?]|flatten)|{"create":(map(select(.=="create"))|length),"update":(map(select(.=="update"))|length),"delete":(map(select(.=="delete"))|length)}' > "${output}"
  ;;
  *)
    terraform "${@}"
  ;;
esac
