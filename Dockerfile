ARG BASE_IMAGE

FROM golang:1.16 AS tfplantool

ARG TFPLANTOOL_VERSION
ARG TERRAFORM_BINARY_VERSION

WORKDIR /tfplantool

RUN git clone --branch $TFPLANTOOL_VERSION --depth 1 https://gitlab.com/mattkasa/tfplantool.git .
RUN sed -i -e "/github\.com\/hashicorp\/terraform/s/ v.*\$/ v$TERRAFORM_BINARY_VERSION/" go.mod
RUN go get -d -v ./...
RUN CGO_ENABLED=0 GOOS=linux go build -tags terraform_${TERRAFORM_BINARY_VERSION} -a -installsuffix cgo -o tfplantool .

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

COPY --from=tfplantool /tfplantool/tfplantool /usr/bin/tfplantool

COPY src/bin/gitlab-terraform.sh /usr/bin/gitlab-terraform
RUN chmod +x /usr/bin/gitlab-terraform

# Override ENTRYPOINT since hashicorp/terraform uses `terraform`
ENTRYPOINT []
