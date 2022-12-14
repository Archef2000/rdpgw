#FROM golang as builder
#
#RUN apt-get update && apt-get install -y libpam-dev
#
## add user
#RUN adduser --disabled-password --gecos "" --home /opt/rdpgw --uid 1001 rdpgw
#
## certificate
#RUN mkdir -p /opt/rdpgw && cd /opt/rdpgw && \
#    random=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1) && \
#    openssl genrsa -des3 -passout pass:$random -out server.pass.key 2048 && \
#    openssl rsa -passin pass:$random -in server.pass.key -out key.pem && \
#    rm server.pass.key && \
#    openssl req -new -sha256 -key key.pem -out server.csr \
#    -subj "/C=US/ST=VA/L=SomeCity/O=MyCompany/OU=MyDivision/CN=rdpgw" && \
#    openssl x509 -req -days 365 -in server.csr -signkey key.pem -out server.pem
#
## build rdpgw and set rights
#ARG CACHEBUST
#RUN git clone https://github.com/bolkedebruin/rdpgw.git /app && \
#    cd /app && \
#    go mod tidy -compat=1.19 && \
#    CGO_ENABLED=0 GOOS=linux go build -trimpath -tags '' -ldflags '' -o '/opt/rdpgw/rdpgw' ./cmd/rdpgw && \
#    CGO_ENABLED=1 GOOS=linux go build -trimpath -tags '' -ldflags '' -o '/opt/rdpgw/rdpgw-auth' ./cmd/auth && \
#    chmod +x /opt/rdpgw/rdpgw && \
#    chmod +x /opt/rdpgw/rdpgw-auth && \
#    chmod u+s /opt/rdpgw/rdpgw-auth

FROM bolkedebruin/rdpgw as builder
FROM alpine

ENV OIDC_URL="http://keycloak:8080/auth/realms/rdpgw"
ENV OIDC_ID="rdpgw"
ENV OIDC_SEC="01cd304c-6f43-4480-9479-618eb6fd578f"
ENV ALLOWED_HOSTS=xrdp:3389

#USER 1001

COPY --chown=1001 --from=builder /opt/rdpgw /opt/rdpgw
COPY --chown=1001 --from=builder /etc/passwd /etc/passwd
COPY --chown=1001 --from=builder /etc/ssl/certs /etc/ssl/certs

COPY --chown=1001 rdpgw.yaml /opt/rdpgw/rdpgw.yaml.bak
COPY ./run.sh /run.sh

WORKDIR /opt/rdpgw

ENTRYPOINT ["/bin/sh"]
CMD ["/run.sh"]
