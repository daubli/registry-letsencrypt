#!/usr/bin/env bash
log_lvl_info() {
    NOW=$(date --iso-8601=seconds)
    echo "${NOW} [info] ${1}"
}

log_lvl_error() {
    NOW=$(date --iso-8601=seconds)
    echo "${NOW} [error] ${1}"
}

checkauth() {
    log_lvl_info "Checking authentication configuration..."
    if [[ ! -d auth ]]; then
        createuser
    else
        if [[ ! -f auth/htpasswd ]]; then
            createuser
        fi
    fi
    log_lvl_info "Completed"
}

createuser() {
    echo "date --utc +%FT%TZ Please enter credentials for your registry login"
    mkdir -p auth
    echo "Username"
    read username
    echo -n "Password":
    read -s password
    docker run --rm --entrypoint htpasswd registry:2 -Bbn ${username} ${password} > auth/htpasswd
    log_lvl_info "Authentication configuration completed."
}

waitingforcertificates() {
    log_lvl_info "Checking certificates..."
    until [[ ! -f $PWD/certs/$1.fullchain.pem ]] || [[ ! -f $PWD/certs/$1.key.pem ]]; do
        log_lvl_info "Waiting for certificates in folder $PWD/certs..."
        sleep 2
    done
    log_lvl_info "Complete"

}

###########################
#        MAIN
###########################

#check if a domain name is passed to the function
if [[ -z "$1" ]]; then
    log_lvl_error "Please specify a domain name (e.g. example.com)"
    exit
fi

checkauth
docker-compose up -d
waitingforcertificates
#start docker frontend
log_lvl_info "Starting docker registry frontend for https://$1"
docker run -d -e ENV_DOCKER_REGISTRY_HOST=$1 -e ENV_DOCKER_REGISTRY_PORT=5000 \
    -e ENV_USE_SSL=yes -e ENV_DOCKER_REGISTRY_USE_SSL=1 -v $PWD/certs/$1.key.pem:/etc/apache2/server.key:ro \
    -v $PWD/certs/$1.fullchain.pem:/etc/apache2/server.crt:ro --restart always -p 443:443 \
    konradkleine/docker-registry-frontend:v2