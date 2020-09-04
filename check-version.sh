#!/usr/bin/env bash

MAJOR_VERSION="10"
DOCKER_HUB_UP="linuxserver/jellyfin"
DOCKER_HUB_DOWN="xjasonlyu/jellyfin"

AUTH_DOMAIN="auth.docker.io"
AUTH_SERVICE="registry.docker.io"
AUTH_OFFLINE_TOKEN="1"
AUTH_CLIENT_ID="shell"
API_DOMAIN="registry-1.docker.io"

TOKEN=$(curl -s -X GET -u ${DOCKER_USERNAME}:${DOCKER_PASSWORD} "https://${AUTH_DOMAIN}/token?service=${AUTH_SERVICE}&scope=repository:${DOCKER_HUB_UP}:pull&offline_token=${AUTH_OFFLINE_TOKEN}&client_id=${AUTH_CLIENT_ID}" | jq -r '.token')
VERSION_UP=$(curl -s -H "Authorization: Bearer ${TOKEN}" https://${API_DOMAIN}/v2/${DOCKER_HUB_UP}/tags/list | jq -r '.tags[]' | grep -E '^'"${MAJOR_VERSION}"'\.[0-9.]+' | sort --version-sort | tail -n 1 | cut -d'-' -f1)

TOKEN=$(curl -s -X GET -u ${DOCKER_USERNAME}:${DOCKER_PASSWORD} "https://${AUTH_DOMAIN}/token?service=${AUTH_SERVICE}&scope=repository:${DOCKER_HUB_DOWN}:pull&offline_token=${AUTH_OFFLINE_TOKEN}&client_id=${AUTH_CLIENT_ID}" | jq -r '.token')
VERSION_DOWN=$(curl -s -H "Authorization: Bearer ${TOKEN}" https://${API_DOMAIN}/v2/${DOCKER_HUB_DOWN}/tags/list | jq -r '.tags[]' | grep -E '^[0-9.]+' | sort --version-sort | tail -n 1)

if [ "${VERSION_UP}" == "${VERSION_DOWN}" ]; then
    echo "pass:${VERSION_UP}"
else
    echo "${VERSION_UP}"
fi

exit 0
