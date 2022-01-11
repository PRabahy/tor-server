ARG TOR_VERSION=0.4.6.8@sha256:c262923ffd0bd224a4a4123cf1c88eea11e2314566b7b7e8a1f77969deeb0208

FROM lncm/tor:$TOR_VERSION

# Install s6
USER root
COPY --from=arpaulnet/s6-overlay-stage:2.2.0.3@sha256:637f874a6686ad29699f9d66f14d70b5d5583f76473138f799fbe61300bb37ac / /

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]