FROM arm32v6/alpine as builder

RUN apk add --update \
        openssl \
        git \
    && rm /var/cache/apk/*


ENV LETS_ENCRYPT_VERSION "v1.8"
RUN git clone --branch ${LETS_ENCRYPT_VERSION} https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion.git /docker-letsencrypt-nginx-proxy-companion



FROM arm32v6/alpine

LABEL maintainer="Yves Blusseau <90z7oey02@sneakemail.com> (@blusseau)"

ENV DEBUG=false \
    DOCKER_GEN_VERSION=0.7.4 \
    DOCKER_HOST=unix:///var/run/docker.sock

# Install packages required by the image
RUN apk add --update \
        bash \
        ca-certificates \
        curl \
        jq \
        openssl \
    && rm /var/cache/apk/*

# Install docker-gen
RUN curl -L https://github.com/jwilder/docker-gen/releases/download/${DOCKER_GEN_VERSION}/docker-gen-alpine-linux-armhf-${DOCKER_GEN_VERSION}.tar.gz \
    | tar -C /usr/local/bin -xz

# Install simp_le
COPY --from=builder /docker-letsencrypt-nginx-proxy-companion/install_simp_le.sh /app/install_simp_le.sh
RUN chmod +rx /app/install_simp_le.sh && sync && /app/install_simp_le.sh && rm -f /app/install_simp_le.sh

COPY --from=builder /docker-letsencrypt-nginx-proxy-companion/app/ /app/

WORKDIR /app

ENTRYPOINT [ "/bin/bash", "/app/entrypoint.sh" ]
CMD [ "/bin/bash", "/app/start.sh" ]
