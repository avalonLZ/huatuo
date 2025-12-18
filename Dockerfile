#docker build --network host -t huatuo/huatuo-bamai:latest .
#FROM ubuntu:20.04 AS base
FROM registry-haiyan.local.huya.com/library/ubuntu:20.04-native AS base
USER root
RUN apt-get update && apt-get install -y make curl clang libbpf-dev 
ENV DEBIAN_FRONTEND=noninteractive

# build huatuo components
FROM base AS build
ARG BUILD_PATH=${BUILD_PATH:-/go/huatuo-bamai}
ARG RUN_PATH=${RUN_PATH:-/home/huatuo-bamai}
WORKDIR ${BUILD_PATH}
COPY . .
RUN tar -C /usr/local -xzf go1.23.0.linux-amd64.tar.gz \
    && ln -s /usr/local/go/bin/go /usr/bin/go
RUN make && mkdir -p ${RUN_PATH} && cp -rf ${BUILD_PATH}/_output/* ${RUN_PATH}/
# disable ES in huatuo-bamai.conf
RUN sed -i 's/"http:\/\/127.0.0.1:9200"/""/' ${RUN_PATH}/conf/huatuo-bamai.conf
RUN sleep 99999

# final public image
#FROM alpine:3.22.0 AS run
#ARG RUN_PATH=${RUN_PATH:-/home/huatuo-bamai}
#RUN apk add --no-cache curl
#COPY --from=build ${RUN_PATH} ${RUN_PATH}
#WORKDIR ${RUN_PATH}
#CMD ["./bin/huatuo-bamai", "--region", "example", "--config", "huatuo-bamai.conf"]
