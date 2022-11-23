FROM bolkedebruin/rdpgw as builder
FROM debian:stable-slim

ENV OIDC_URL="http://keycloak:8080/auth/realms/rdpgw"
ENV OIDC_ID="rdpgw"
ENV OIDC_SEC="01cd304c-6f43-4480-9479-618eb6fd578f"
ENV ALLOWED_HOSTS=xrdp:3389

ADD tmp.tar /
RUN ls -al /
USER 1001

COPY --chown=1001 --from=builder /opt/rdpgw /opt/rdpgw
COPY --chown=1001 --from=builder /etc/passwd /etc/passwd
COPY --chown=1001 --from=builder /etc/ssl/certs /etc/ssl/certs

COPY --chown=1001 rdpgw.yaml /opt/rdpgw/rdpgw.yaml.bak
COPY ./run.sh /run.sh

WORKDIR /opt/rdpgw

ENTRYPOINT ["/bin/bash"]
CMD ["/run.sh"]
