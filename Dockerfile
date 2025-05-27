ARG PGVECTORS_TAG
ARG VCHORD_TAG
ARG BITNAMI_TAG
FROM tensorchord/pgvecto-rs-binary:pg${BITNAMI_TAG%%.*}-${PGVECTORS_TAG}-${TARGETARCH} AS pgvectors

ARG VCHORD_TAG
ARG BITNAMI_TAG
FROM tensorchord/vchord-binary:pg${BITNAMI_TAG%%.*}-v${VCHORD_TAG}-${TARGETARCH} AS vchord
COPY /workspace/postgresql-${BITNAMI_TAG%%.*}-vchord_${VCHORD_TAG}-1_${TARGETARCH}.deb /workspace/vchord.deb

FROM debian:bullseye-slim AS builder

COPY --from=pgvectors /pgvecto-rs-binary-release.deb /
RUN dpkg -x /pgvecto-rs-binary-release.deb /tmp/pgvectors

COPY --from=vchord /workspace/vchord.deb /
RUN dpkg -x /vchord.deb /tmp/vchord

ARG BITNAMI_TAG
FROM bitnami/postgresql:${BITNAMI_TAG}

ARG BITNAMI_TAG

# drop to root to install packages
USER root

COPY --from=builder /tmp/pgvectors/usr/lib/postgresql/${BITNAMI_TAG%%.*}/lib/* /opt/bitnami/postgresql/lib/
COPY --from=builder /tmp/pgvectors/usr/share/postgresql/${BITNAMI_TAG%%.*}/extension/* /opt/bitnami/postgresql/share/extension/
COPY --from=builder /tmp/vchord/usr/lib/postgresql/${BITNAMI_TAG%%.*}/lib/* /opt/bitnami/postgresql/lib/
COPY --from=builder /tmp/vchord/usr/share/postgresql/${BITNAMI_TAG%%.*}/extension/* /opt/bitnami/postgresql/share/extension/

USER 1001

ENV POSTGRESQL_EXTRA_FLAGS="-c shared_preload_libraries=vectors.so,vchord.so"
