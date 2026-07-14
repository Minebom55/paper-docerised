#!/bin/bash
set -euo pipefail

#if [ ! -e ./server ]; then
#    mkdir -p server
#fi

cd server

paper_url=$(curl -s "https://fill.papermc.io/v3/projects/paper/versions/${MC_VERSION}/builds/latest" | jq -r '.downloads["server:default"].url')

if [ -z "$paper_url" ] || [ "$paper_url" = "null" ]; then
    echo "Failed to resolve Paper download URL for version ${MC_VERSION}" >&2
    exit 1
fi

rm -f ./*.jar
curl -fsSL "$paper_url" -o paper.jar

if [ ! -e eula.txt ]; then
    java -Xmx${RAM:-2}G -Xms1G -jar paper.jar nogui
    echo "eula=true" > eula.txt
fi

RAM=${MC_RAM:-2}
exec java -Xmx${RAM}G -Xms1G -jar paper.jar nogui
