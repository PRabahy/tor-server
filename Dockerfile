FROM lncm/tor:0.4.6.8

# Install s6
USER root
COPY --from=arpaulnet/s6-overlay-stage:2.2.0.3@sha256:637f874a6686ad29699f9d66f14d70b5d5583f76473138f799fbe61300bb37ac / /

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]