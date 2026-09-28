#!/bin/bash
set -euo pipefail

#if [ ! -e ./server ]; then
#    mkdir -p server
#fi

reset_properties="${reset_properties%\"}"
reset_properties="${reset_properties#\"}"

reset_paper_config="${reset_paper_config%\"}"
reset_paper_config="${reset_paper_config#\"}"

cd server
enabled="${enabled%\"}"
enabled="${enabled#\"}"
echo "${enabled}"
if [ "${enabled}" == "false" ]; then
    echo "Server is disabled. Exiting."
    exit 0
fi

paper_url=$(curl -s "https://fill.papermc.io/v3/projects/paper/versions/${MC_VERSION}/builds/latest" | jq -r '.downloads["server:default"].url')

if [ -z "$paper_url" ] || [ "$paper_url" = "null" ]; then
    echo "Failed to resolve Paper download URL for version ${MC_VERSION}" >&2
    exit 1
fi

rm -f ./*.jar
curl -fsSL "$paper_url" -o paper.jar

if [ "${reset_properties}" = "true" ]; then
    echo "Resetting server.properties as requested."
    rm -f server.properties
else
    echo "server.properties reset not requested. Keeping existing configuration."
fi

if [ ! -e eula.txt ]; then
    java -Xmx${RAM:-2}G -Xms1G -jar paper.jar nogui
    echo "eula=true" > eula.txt
fi

if [ ! -e server.properties ]; then
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
online-mode=false
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

if [ "${reset_paper_config}" = "true" ]; then
    echo "Resetting Paper configuration as requested."
    rm -f ./config/paper-global.yml
else
    echo "Paper configuration reset not requested. Keeping existing configuration."
fi

if [ "${velocity_secret}" = "" ]; then
    echo "Velocity secret is not set. Please set the velocity_secret environment variable."
    exit 1
fi

if [ ! -e ./config/paper-global.yml ]; then
    mkdir -p ./config
    echo "# This is the global configuration file for Paper.
# As you can see, there's a lot to configure. Some options may impact gameplay, so use
# with caution, and make sure you know what each option does before configuring.
# 
# If you need help with the configuration or have any questions related to Paper,
# join us in our Discord or check the docs page.
# 
# The world configuration options have been moved inside
# their respective world folder. The files are named paper-world.yml
# 
# File Reference: https://docs.papermc.io/paper/reference/global-configuration/
# Docs: https://docs.papermc.io/
# Discord: https://discord.gg/papermc
# Website: https://papermc.io/

_version: 31
anticheat:
  obfuscation:
    items:
      all-models:
        also-obfuscate: []
        dont-obfuscate:
        - minecraft:lodestone_tracker
        sanitize-count: true
      enable-item-obfuscation: false
      model-overrides:
        minecraft:elytra:
          also-obfuscate: []
          dont-obfuscate:
          - minecraft:damage
          sanitize-count: true
block-updates:
  disable-chorus-plant-updates: false
  disable-mushroom-block-updates: false
  disable-noteblock-updates: false
  disable-tripwire-updates: false
chunk-loading-advanced:
  auto-config-send-distance: true
  player-max-concurrent-chunk-generates: 0
  player-max-concurrent-chunk-loads: 0
chunk-loading-basic:
  player-max-chunk-generate-rate: -1.0
  player-max-chunk-load-rate: 100.0
  player-max-chunk-send-rate: 75.0
chunk-system:
  io-threads: -1
  worker-threads: -1
collisions:
  enable-player-collisions: true
  send-full-pos-for-hard-colliding-entities: true
commands:
  ride-command-allow-player-as-vehicle: false
  suggest-player-names-when-null-tab-completions: true
  time-command-affects-all-worlds: false
console:
  enable-brigadier-completions: true
  enable-brigadier-highlighting: true
  has-all-permissions: false
item-validation:
  book:
    author: 8192
    page: 16384
    title: 8192
  book-size:
    page-max: 2560
    total-multiplier: 0.98
  display-name: 8192
  lore-line: 8192
  resolve-selectors-in-books: false
logging:
  deobfuscate-stacktraces: true
messages:
  kick:
    authentication-servers-down: <lang:multiplayer.disconnect.authservers_down>
    connection-throttle: Connection throttled! Please wait before reconnecting.
    flying-player: <lang:multiplayer.disconnect.flying>
    flying-vehicle: <lang:multiplayer.disconnect.flying>
  no-permission: <red>I'm sorry, but you do not have permission to perform this command.
    Please contact the server administrators if you believe that this is in error.
  use-display-name-in-quit-message: false
misc:
  chat-threads:
    chat-executor-core-size: -1
    chat-executor-max-size: -1
  client-interaction-leniency-distance: default
  compression-level: default
  enable-nether: true
  fix-far-end-terrain-generation: true
  load-permissions-yml-before-plugins: true
  max-joins-per-tick: 5
  max-tracking-combat-entries: 10240
  prevent-negative-villager-demand: false
  region-file-cache-size: 256
  send-full-pos-for-item-entities: false
  strict-advancement-dimension-check: false
  use-alternative-luck-formula: false
  use-dimension-type-for-custom-spawners: false
  xp-orb-groups-per-area: default
packet-limiter:
  all-packets:
    action: KICK
    interval: 7.0
    max-packet-rate: 500.0
  kick-message: <red><lang:disconnect.exceeded_packet_rate>
  overrides:
    minecraft:place_recipe:
      action: DROP
      interval: 4.0
      max-packet-rate: 5.0
player-auto-save:
  max-per-tick: -1
  rate: -1
proxies:
  bungee-cord:
    online-mode: true
  proxy-protocol: false
  velocity:
    enabled: true
    online-mode: true
    secret: '${velocity_secret}'
scoreboards:
  save-empty-scoreboard-teams: true
  track-plugin-scoreboards: false
spam-limiter:
  incoming-packet-threshold: 300
  recipe-spam-increment: 1
  recipe-spam-limit: 20
  tab-spam-increment: 1
  tab-spam-limit: 500
spark:
  enable-immediately: false
  enabled: true
time:
  affects-all-worlds: false
unsupported-settings:
  allow-headless-pistons: false
  allow-permanent-block-break-exploits: false
  allow-piston-duplication: false
  allow-unsafe-end-portal-teleportation: false
  compression-format: ZLIB
  oversized-item-component-sanitizer:
    dont-sanitize: []
  perform-username-validation: true
  skip-tripwire-hook-placement-validation: false
  skip-vanilla-damage-tick-when-shield-blocked: false
  update-equipment-on-player-actions: true
update-checker:
  enabled: true
watchdog:
  early-warning-delay: 10000
  early-warning-every: 5000
" > ./config/paper-global.yml
fi

#Plugin installation
rm -f ./plugins/*.jar

for plugin in /docker/custom_plugins/*.jar; do
    [ -f "$plugin" ] || continue
    echo "Copying custom plugin: $(basename "$plugin")"
    cp "$plugin" ./plugins/
done

plugin_ids="${MODRINTH_PROJECTS:-$PROJECT_ID}"

if [ -n "$plugin_ids" ]; then
    IFS=',' read -r -a ids <<< "$plugin_ids"
    for project_id in "${ids[@]}"; do
        project_id="$(echo "$project_id" | xargs)"
        [ -z "$project_id" ] && continue

        echo "Checking Modrinth plugin: $project_id"
        loaders=$(printf '["paper"]' | jq -sRr @uri)
        versions=$(printf '["%s"]' "$MC_VERSION" | jq -sRr @uri)
        versiondata=$(curl -fsSL -s "https://api.modrinth.com/v3/project/$project_id/version?loaders=$loaders&game_versions=$versions&limit=1")
        pluginurl=$(echo "$versiondata" | jq -r '.[0].files[0].url')
        filename=$(echo "$versiondata" | jq -r '.[0].files[0].filename')
        returned_versions=$(echo "$versiondata" | jq -r '.[0].game_versions | join(",")')

        if [ -z "$pluginurl" ] || [ "$pluginurl" = "null" ] || [ -z "$returned_versions" ] || ! echo ",$returned_versions," | grep -q ",${MC_VERSION},"; then
            echo "No compatible version found for $project_id"
            echo "  Requested MC version: $MC_VERSION"
            echo "  Returned game versions: ${returned_versions:-none}"
            exit 1 #comment out this line if you want to skip plugins that don't have a compatible version
            continue
        fi

        echo "Downloading compatible plugin: $project_id"
        curl -fsSL "$pluginurl" -o "plugins/$filename"
    done
else
    echo "No Modrinth plugin IDs provided"
fi

RAM=${MC_RAM:-2}
exec java -Xmx${RAM}G -Xms1G -jar paper.jar nogui
