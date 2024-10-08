ARG BITNAMI_TAG

FROM bitnami/postgresql:$BITNAMI_TAG
ARG BITNAMI_TAG
ARG PGVECTORS_TAG
ARG TARGETARCH

# drop to root to install packages
USER root

ADD https://github.com/tensorchord/pgvecto.rs/releases/download/$PGVECTORS_TAG/vectors-pg${BITNAMI_TAG%%.*}_${PGVECTORS_TAG#"v"}_${TARGETARCH}.deb pgvectors.deb

RUN mkdir /tmp/pgvectors && \
    dpkg -x pgvectors.deb /tmp/pgvectors && \
    cp -r /tmp/pgvectors/usr/lib/postgresql/${BITNAMI_TAG%%.*}/lib/* /opt/bitnami/postgresql/lib/ && \
    cp -r /tmp/pgvectors/usr/share/postgresql/${BITNAMI_TAG%%.*}/extension/* /opt/bitnami/postgresql/share/extension/ && \
    rm -rf /tmp/pgvectors pgvectors.deb

USER 1001
