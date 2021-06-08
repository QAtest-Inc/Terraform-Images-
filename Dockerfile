ARG BASE_IMAGE

FROM $BASE_IMAGE

ARG TERRAFORM_BINARY_VERSION

RUN apk add --no-cache jq curl git openssh

WORKDIR /tmp

RUN ( curl -sLo terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_BINARY_VERSION}/terraform_${TERRAFORM_BINARY_VERSION}_linux_amd64.zip" && \
      unzip terraform.zip && \
      rm terraform.zip && \
      mv ./terraform /usr/local/bin/terraform \
    ) && terraform --version

WORKDIR /

COPY src/bin/gitlab-terraform.sh /usr/bin/gitlab-terraform
RUN chmod +x /usr/bin/gitlab-terraform

# Override ENTRYPOINT since hashicorp/terraform uses `terraform`
ENTRYPOINT []
