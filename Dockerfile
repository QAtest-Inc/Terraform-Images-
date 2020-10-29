ARG BASE
ARG TERRAFORM_BASE

FROM golang:1.14 AS tfplantool

ARG BASE
ARG TERRAFORM_BASE
ARG TFPLANTOOL

WORKDIR /tfplantool

RUN git clone --branch $TFPLANTOOL --depth 1 https://gitlab.com/mattkasa/tfplantool.git .
RUN sed -i -e "/github\.com\/hashicorp\/terraform/s/ v.*\$/ v$(echo "$TERRAFORM_BASE" | sed -e "s/^.*://")/" go.mod
RUN go get -d -v ./...
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o tfplantool .

FROM $TERRAFORM_BASE AS terraform

ARG BASE

FROM $BASE

RUN apk add --no-cache ca-certificates jq

COPY --from=terraform /bin/terraform /bin/terraform
COPY --from=tfplantool /tfplantool/tfplantool /usr/bin/tfplantool

COPY src/bin/gitlab-terraform.sh /usr/bin/gitlab-terraform
RUN chmod +x /usr/bin/gitlab-terraform

RUN npm install -g cdktf-cli && npm cache clean --force

COPY src/bin/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
