# docker-siyuan

## Overview
SiYuan docker image based on debian:bullseye-slim, run with root user by default.

## Quick start

```bash
docker run -p 6806:6806 --rm jearton1024/siyuan -workspace=/siyuan/workspace -lang=zh_CN
```

Open http://localhost:6806 in your browser.

## Environment

|Key|Value|Example|
|---|---|---|
|REFRESH_CRON_JOB|on/off, default is off|on|
|REFRESH_CRON_EXPR|a crontab expression starting with minutes|1-59/15 * * * *|

## Add cronjob to refresh file tree

Not supported prior to v2.0.15-bullseye-slim. Example: [docker-compose.yml](docker-compose.yml)

## Chaned features

1. Base on `debian:bullseye-slim` image, instead of `Alpine`.
2. Set default locale to `zh_CN.UTF-8`, instead of `en_US`.
3. Since v2.0.15-bullseye-slim, you can optionally configure a cron job to refresh the file tree. And the log directory is `siyuan/logs`.

## Development

Build the image and push to the remote.

```bash
docker login
./build.sh
```