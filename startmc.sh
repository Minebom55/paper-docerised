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
    echo "#Minecraft server properties
#Tue Jul 14 19:59:01 UTC 2026
accepts-transfers=false
allow-flight=false
broadcast-console-to-ops=true
broadcast-rcon-to-ops=true
bug-report-link=
debug=false
difficulty=easy
enable-code-of-conduct=false
enable-jmx-monitoring=false
enable-query=false
enable-rcon=true
enable-status=true
enforce-secure-profile=true
enforce-whitelist=false
entity-broadcast-range-percentage=100
force-gamemode=false
function-permission-level=2
gamemode=survival
generate-structures=true
generator-settings={}
hardcore=false
hide-online-players=false
initial-disabled-packs=
initial-enabled-packs=vanilla
level-name=world
level-seed=
level-type=minecraft\:normal
log-ips=true
management-server-allowed-origins=
management-server-enabled=false
management-server-host=localhost
management-server-port=0
management-server-secret=6wRqfevV1aVizhq0XmaYuV6JF0kVasKeY3ek5zYT
management-server-tls-enabled=true
management-server-tls-keystore=
management-server-tls-keystore-password=
max-chained-neighbor-updates=1000000
max-players=20
max-tick-time=60000
max-world-size=29999984
motd=A Minecraft Server
network-compression-threshold=256
online-mode=true
op-permission-level=4
pause-when-empty-seconds=-1
player-idle-timeout=0
prevent-proxy-connections=false
query.port=25565
rate-limit=0
rcon.password=changeMe
rcon.port=${rcon_port}
region-file-compression=deflate
require-resource-pack=false
resource-pack=
resource-pack-id=
resource-pack-prompt=
resource-pack-sha1=
server-ip=
server-port=${port}
simulation-distance=10
spawn-protection=16
status-heartbeat-interval=0
sync-chunk-writes=true
text-filtering-config=
text-filtering-version=0
use-native-transport=true
view-distance=10
white-list=false
" > server.properties
fi

#Plugin installation
rm -f ./plugins/*.jar


loaders=$(printf '["paper"]' | jq -sRr @uri)
versions=$(printf '["%s"]' "$MC_VERSION" | jq -sRr @uri)
versiondata=$(curl -s "https://api.modrinth.com/v3/project/$PROJECT_ID/version?loaders=$loaders&game_versions=$versions&limit=1")
pluginurl=$(echo "$versiondata" | jq -r '.[0].files[0].url')
filename=$(echo "$versiondata" | jq -r '.[0].files[0].filename')
if [ -z "$pluginurl" ] || [ "$pluginurl" = "null" ]; then
    echo "No compatible version found"
    exit 1
fi
curl -fsSL "$pluginurl" -o "plugins/$filename"


RAM=${MC_RAM:-2}
exec java -Xmx${RAM}G -Xms1G -jar paper.jar nogui
