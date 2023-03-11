# syntax=docker/dockerfile:1
# https://github.com/siyuan-note/siyuan/releases
# https://github.com/siyuan-note/siyuan/blob/master/Dockerfile

# download source code and build frontend part
FROM node:16 as NODE_BUILD
ARG SIYUAN_VERSION
RUN set -ex \
    && apt-get update \
    && apt-get install -y git \
    && mkdir -p /go/src/github.com/siyuan-note \
    && cd /go/src/github.com/siyuan-note \
    && git clone -b "${SIYUAN_VERSION}" --depth=1 https://github.com/siyuan-note/siyuan.git \
    && cd siyuan/app \
    && npm install -g pnpm \
    && pnpm install \
    && pnpm run build

# build backend part
FROM golang:bullseye as GO_BUILD
COPY --from=NODE_BUILD /go/src/github.com/siyuan-note/siyuan/ /go/src/github.com/siyuan-note/siyuan/
WORKDIR /go/src/github.com/siyuan-note/siyuan/
ENV GO111MODULE=on
ENV CGO_ENABLED=1
RUN set -ex \
    && apt-get update \
    && apt-get install -y gcc musl-dev git \
    && cd kernel && go build --tags fts5 -v -ldflags "-s -w -X github.com/siyuan-note/siyuan/kernel/util.Mode=prod" \
    && mkdir /opt/siyuan/ \
    && mv /go/src/github.com/siyuan-note/siyuan/app/appearance/ /opt/siyuan/ \
    && mv /go/src/github.com/siyuan-note/siyuan/app/stage/ /opt/siyuan/ \
    && mv /go/src/github.com/siyuan-note/siyuan/app/guide/ /opt/siyuan/ \
    && mv /go/src/github.com/siyuan-note/siyuan/kernel/kernel /opt/siyuan/ \
    && find /opt/siyuan/ -name .git | xargs rm -rf

# copy run-related scripts into target image
COPY opt/siyuan /opt/siyuan/

#--------------- final image ---------------
FROM debian:bullseye-slim
LABEL maintainer="jearton1024 <jearton1024@gmail.com>"

ENV TZ=Asia/Shanghai
ENV LANG=zh_CN.UTF-8
ENV LC_ALL=zh_CN.UTF-8
ENV LANGUAGE=zh_CN.UTF-8
ENV REFRESH_CRON_JOB=off
ENV REFRESH_CRON_EXPR=
ENV RUN_IN_CONTAINER=true

COPY --from=GO_BUILD /opt/siyuan/ /opt/siyuan/
WORKDIR /opt/siyuan/

RUN set -ex \
    && apt-get update \
    # install packages
    && DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates locales curl cron \
    # set default locale
    && sed -i 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG="$LANG" LC_ALL="$LC_ALL" LANGUAGE="$LANGUAGE" \
    && rm -rf /usr/share/i18n \
    # set timezone
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    # clear install cache
    && rm -rf /var/lib/apt/lists/* \
    # make shell file executable
    && chmod a+x /opt/siyuan/entrypoint.sh \
    && chmod a+x /opt/siyuan/refresh-siyuan.sh

EXPOSE 6806

ENTRYPOINT [ "/opt/siyuan/entrypoint.sh" ]
