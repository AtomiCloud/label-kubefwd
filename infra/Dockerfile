FROM alpine:3.18
WORKDIR /app
ARG UID=10001
ARG GID=10001
RUN addgroup -g "${GID}" bash-user && adduser -D -u "${UID}" -G bash-user bash-user
RUN apk --no-cache add \
    bash==5.2.15-r5 \
    grep==3.10-r1 \
    sed==4.9-r2 \
    gawk==5.2.2-r0 \
    jq==1.6-r3 \
    yq==4.33.3-r2 && \
    apk --no-cache add \
    kubectl==1.27.4-r1 \
    --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community
USER bash-user
COPY --chown=bash-user:bash-user ./src .
CMD ["/app/main.sh", "/app/services.yaml"]
