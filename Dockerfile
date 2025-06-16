ARG BITNAMI_TAG
ARG PGVECTOR_TAG

FROM pgvector/pgvector:${PGVECTOR_TAG}-pg${BITNAMI_TAG%%.*} AS pgvector

FROM debian:bullseye-slim AS builder
ARG PGVECTORS_TAG
ARG VECTORCHORD_TAG
ARG BITNAMI_TAG
ARG TARGETARCH

RUN apt-get update && \
    apt-get install -y wget
# Install VectorChord
RUN wget -nv -O /tmp/vchord.deb https://github.com/tensorchord/VectorChord/releases/download/${VECTORCHORD_TAG}/postgresql-${BITNAMI_TAG%%.*}-vchord_${VECTORCHORD_TAG#"v"}-1_${TARGETARCH}.deb && \
    dpkg -x /tmp/vchord.deb /tmp
# Install pgvectors
RUN if [ -n "${PGVECTORS_TAG}" ]; then \
        wget -nv -O /tmp/pgvectors.deb https://github.com/tensorchord/pgvecto.rs/releases/download/v${PGVECTORS_TAG}/vectors-pg${BITNAMI_TAG%%.*}_${PGVECTORS_TAG#"v"}_${TARGETARCH}$(if [ "${PGVECTORS_TAG}" = '0.3.0' ]; then echo "_vectors"; fi).deb; \
        dpkg -x /tmp/pgvectors.deb /tmp; \
    fi

FROM bitnami/postgresql:${BITNAMI_TAG}
ARG BITNAMI_TAG

# drop to root to install packages
USER root
COPY --from=pgvector /usr/lib/postgresql/${BITNAMI_TAG%%.*}/lib/vector.so /opt/bitnami/postgresql/lib/
COPY --from=pgvector /usr/share/postgresql/${BITNAMI_TAG%%.*}/extension/vector* /opt/bitnami/postgresql/share/extension/
COPY --from=builder /tmp/usr/lib/postgresql/${BITNAMI_TAG%%.*}/lib/* /opt/bitnami/postgresql/lib/
COPY --from=builder /tmp/usr/share/postgresql/${BITNAMI_TAG%%.*}/extension/* /opt/bitnami/postgresql/share/extension/


USER 1001

ENV POSTGRESQL_EXTRA_FLAGS="-c shared_preload_libraries=vectors.so,vector.so,vchord.so"
