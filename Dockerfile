ARG TOR_VERSION=0.4.7.13
ARG TOR_CHECKSUM=@sha256:5a3cfb478d978feb1426ce6dca8e10906bbdd72cff94d7c0c589339f717b2503

FROM lncm/tor:${TOR_VERSION}${TOR_CHECKSUM}

# Install s6
USER root
COPY --from=arpaulnet/s6-overlay-stage:2.2.0.3@sha256:637f874a6686ad29699f9d66f14d70b5d5583f76473138f799fbe61300bb37ac / /

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
