#!/bin/bash
set -euo pipefail

if [ ! -e ./server ]; then
    mkdir -p server
fi

cd server

api_response=$(curl -fsSL "https://api.papermc.io/v2/projects/paper/versions/${MC_VERSION}/builds/latest")
paper_url=$(printf '%s' "$api_response" | jq -r '.downloads.application.url // .downloads["server:default"].url')

if [ -z "$paper_url" ] || [ "$paper_url" = "null" ]; then
    echo "Failed to resolve Paper download URL for version ${MC_VERSION}" >&2
    exit 1
fi

rm -f ./*.jar
curl -fsSL "$paper_url" -o paper.jar

if [ ! -e eula.txt ]; then
    echo "eula=${EULA:-false}" > eula.txt
fi

exec java -Xmx${MC_RAM:-1G} -jar paper.jar nogui

