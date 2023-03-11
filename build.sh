#!/usr/bin/env bash
SIYUAN_VERSION=v2.7.9
docker build --build-arg SIYUAN_VERSION=${SIYUAN_VERSION} --tag jearton1024/siyuan .

docker image tag jearton1024/siyuan:latest jearton1024/siyuan:${SIYUAN_VERSION}-bullseye-slim

docker push jearton1024/siyuan:${SIYUAN_VERSION}-bullseye-slim
docker push jearton1024/siyuan:latest
