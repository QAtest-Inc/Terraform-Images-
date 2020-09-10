ARG BASE

FROM golang:1.14 AS tfplantool

ARG BASE
ARG TFPLANTOOL

WORKDIR /tfplantool

RUN git clone --branch $TFPLANTOOL --depth 1 https://gitlab.com/mattkasa/tfplantool.git .
RUN sed -i -e "/github\.com\/hashicorp\/terraform/s/ v.*\$/ v$(echo "$BASE" | sed -e "s/^.*://")/" go.mod
RUN go get -d -v ./...
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o tfplantool .

FROM $BASE

RUN apk add --no-cache jq

COPY --from=tfplantool /tfplantool/tfplantool /usr/bin/tfplantool

COPY src/bin/gitlab-terraform.sh /usr/bin/gitlab-terraform
RUN chmod +x /usr/bin/gitlab-terraform

# Override ENTRYPOINT since hashicorp/terraform uses `terraform`
ENTRYPOINT []
