FROM bolkedebruin/rdpgw as builder
FROM alpine

USER 1001

COPY --chown=1001 --from=builder /opt/rdpgw /opt/rdpgw
COPY --chown=1001 --from=builder /etc/passwd /etc/passwd
COPY --chown=1001 --from=builder /etc/ssl/certs /etc/ssl/certs

COPY --chown=1001 rdpgw.yaml /opt/rdpgw/rdpgw.yaml
COPY ./run.sh /run.sh

WORKDIR /opt/rdpgw

ENTRYPOINT ["/bin/sh"]
CMD ["/run.sh"]
