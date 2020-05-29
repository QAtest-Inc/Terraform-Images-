ARG BASE=hashicorp/terraform:latest
FROM $BASE

RUN apk add --no-cache jq

COPY src/bin/gitlab-terraform.sh /usr/bin/gitlab-terraform
RUN chmod +x /usr/bin/gitlab-terraform

# Override ENTRYPOINT since hashicorp/terraform uses `terraform`
ENTRYPOINT []
