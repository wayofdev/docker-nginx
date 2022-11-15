# Auto-generated via Ansible: edit src/Dockerfiles/all/Dockerfile.j2 instead.

FROM nginx:mainline-alpine

# Labels
# https://github.com/opencontainers/image-spec/blob/main/annotations.md
LABEL "maintainer"="lotyp <lotyp7@gmail.com>"
LABEL "vendor"="wayofdev"
LABEL "org.opencontainers.image.authors"="lotyp <lotyp7@gmail.com>"
LABEL "org.opencontainers.image.url"="https://hub.docker.com/r/wayofdev/nginx"
LABEL "org.opencontainers.image.documentation"="https://github.com/wayofdev/docker-nginx"
LABEL "org.opencontainers.image.source"="https://github.com/wayofdev/docker-nginx"
LABEL "org.opencontainers.image.vendor"="wayofdev"
LABEL "org.opencontainers.image.licenses"="MIT"
LABEL "org.opencontainers.image.ref.name"="k8s-alpine"
LABEL "org.opencontainers.image.title"="nginx-k8s-alpine"
LABEL "org.opencontainers.image.description"="nginx-k8s-alpine"

ENV LANG="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"

ENV PHP_UPSTREAM_CONTAINER=app
ENV PHP_UPSTREAM_PORT=9000

RUN set -eux; \
    apk -U upgrade -a \
    && adduser -u 82 -D -S -G www-data www-data \
    && mkdir -p /etc/nginx/ssl \
    && mkdir -p /app/public \
    && mkdir -p /var/cache/nginx \
    && cp /usr/share/nginx/html/index.html /app/public/

COPY ./configs/00-set-upstream.sh /docker-entrypoint.d
COPY ./configs/00_upstream.conf /etc/nginx/conf.d/00_upstream.conf
COPY ./configs/default.conf /etc/nginx/conf.d/default.conf
COPY ./configs/nginx.conf /etc/nginx/

COPY ./certs/ /etc/nginx/ssl/

RUN set -eux \
    && chown 82:82 /docker-entrypoint.d/00-set-upstream.sh \
    && chmod +x /docker-entrypoint.d/00-set-upstream.sh \
    && chown 82:82 /etc/nginx/conf.d/00_upstream.conf \
    && chown 82:82 -R /var/cache/nginx \
    && touch /var/run/nginx.pid \
    && chown 82:82 /var/run/nginx.pid \
    && chown 82:82 -R /etc/nginx/ssl

USER 82

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8880 8443

STOPSIGNAL SIGQUIT

CMD ["nginx"]
