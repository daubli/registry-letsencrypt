#!/usr/bin/env bash

log_lvl_info() {
    NOW=$(date --iso-8601=seconds)
    echo "${NOW} [info] ${1}"
}

log_lvl_info "Stop registry service stack..."
docker container stop registryui
docker-compose stop