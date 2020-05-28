ARG BASE=hashicorp/terraform:latest
FROM $BASE

RUN apk add --no-cache jq

# Override ENTRYPOINT since hashicorp/terraform uses `terraform`
ENTRYPOINT []
