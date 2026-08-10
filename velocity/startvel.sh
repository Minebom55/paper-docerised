#!/bin/bash
set -euo pipefail

#if [ ! -e ./server ]; then
#    mkdir -p server
#fi

reset_toml="${reset_toml%\"}"
reset_toml="${reset_toml#\"}"

cd server
enabled="${enabled%\"}"
enabled="${enabled#\"}"

echo "${enabled}"
if [ "${enabled}" == "false" ]; then
    echo "Server is disabled. Exiting."
    exit 0
fi

#Automatic server port configuration
servers_ports="${servers_ports%\"}"
servers_ports="${servers_ports#\"}"

if [ -z "${servers_ports:-}" ]; then
    echo "Error: servers_ports is not set or empty" >&2
    exit 1
fi

servers_block=""
try_lines=""
IFS=',' read -r -a server_entries <<< "$servers_ports"
for entry in "${server_entries[@]}"; do
    entry="${entry#${entry%%[![:space:]]*}}"
    entry="${entry%${entry##*[![:space:]]}}"

    if [ -z "$entry" ]; then
        continue
    fi

    if ! echo "$entry" | grep -q ':'; then
        echo "Error: invalid servers_ports entry '$entry'. Expected format name:port" >&2
        exit 1
    fi

    name="${entry%%:*}"
    port="${entry#*:}"

    if [ -z "$name" ] || [ -z "$port" ]; then
        echo "Error: invalid servers_ports entry '$entry'. Expected format name:port" >&2
        exit 1
    fi

    if ! printf '%s' "$port" | grep -qE '^[0-9]+$'; then
        echo "Error: invalid port '$port' for server '$name'. Port must be numeric." >&2
        exit 1
    fi

    servers_block="${servers_block}${name} = \"${name}:25565\"\n"
    try_lines="${try_lines}    \"${name}\",\n"
done

if [ -z "$servers_block" ]; then
    echo "Error: servers_ports must contain at least one valid name:port pair" >&2
    exit 1
fi

try_lines="${try_lines%,\n}"

velocity_url=$(curl -s "https://fill.papermc.io/v3/projects/velocity/versions/${velocity_version}/builds/latest" | jq -r '.downloads["server:default"].url')

if [ -z "$velocity_url" ] || [ "$velocity_url" = "null" ]; then
    echo "Failed to resolve Paper download URL for version ${MC_VERSION}" >&2
    exit 1
fi

rm -f ./*.jar
curl -fsSL "$velocity_url" -o velocity.jar
if [ "${reset_toml}" = "true" ]; then
    echo "Resetting velocity.toml as requested."
    rm -f velocity.toml
else
    echo "Not resetting velocity.toml."
fi
if [ ! -f velocity.toml ]; then

cat > velocity.toml <<EOF
# Config version. Do not change this
config-version = "2.8"

# What port should the proxy be bound to? By default, we'll bind to all addresses on port 25565.
bind = "0.0.0.0:${server_port}"

# What should be the MOTD? This gets displayed when the player adds your server to
# their server list. Only MiniMessage format is accepted.
motd = "<#09add3>A Velocity Server"

# What should we display for the maximum number of players? (Velocity does not support a cap
# on the number of players online.)
show-max-players = 500

# Should we authenticate players with Mojang? By default, this is on.
online-mode = true

# Should the proxy enforce the new public key security standard? By default, this is on.
force-key-authentication = true

# If client's ISP/AS sent from this proxy is different from the one from Mojang's
# authentication server, the player is kicked. This disallows some VPN and proxy
# connections but is a weak form of protection.
prevent-client-proxy-connections = false

# Should we forward IP addresses and other data to backend servers?
# Available options:
# - "none":        No forwarding will be done. All players will appear to be connecting
#                  from the proxy and will have offline-mode UUIDs.
# - "legacy":      Forward player IPs and UUIDs in a BungeeCord-compatible format. Use this
#                  if you run servers using Minecraft 1.12 or lower.
# - "bungeeguard": Forward player IPs and UUIDs in a format supported by the BungeeGuard
#                  plugin. Use this if you run servers using Minecraft 1.12 or lower, and are
#                  unable to implement network level firewalling (on a shared host).
# - "modern":      Forward player IPs and UUIDs as part of the login process using
#                  Velocity's native forwarding. Only applicable for Minecraft 1.13 or higher.
player-info-forwarding-mode = "modern"

# If you are using modern or BungeeGuard IP forwarding, configure a file that contains a unique secret here.
# The file is expected to be UTF-8 encoded and not empty.
forwarding-secret-file = "forwarding.secret"

# Announce whether or not your server supports Forge. If you run a modded server, we
# suggest turning this on.
# 
# If your network runs one modpack consistently, consider using ping-passthrough = "mods"
# instead for a nicer display in the server list.
announce-forge = false

# If enabled (default is false) and the proxy is in online mode, Velocity will kick
# any existing player who is online if a duplicate connection attempt is made.
kick-existing-players = true

# Should Velocity pass server list ping requests to a backend server?
# Available options:
# - "disabled":    No pass-through will be done. The velocity.toml and server-icon.png
#                  will determine the initial server list ping response.
# - "mods":        Passes only the mod list from your backend server into the response.
#                  The first server in your try list (or forced host) with a mod list will be
#                  used. If no backend servers can be contacted, Velocity won't display any
#                  mod information.
# - "description": Uses the description and mod list from the backend server. The first
#                  server in the try (or forced host) list that responds is used for the
#                  description and mod list.
# - "all":         Uses the backend server's response as the proxy response. The Velocity
#                  configuration is used if no servers could be contacted.
ping-passthrough = "DISABLED"

# If enabled (default is false), then a sample of the online players on the proxy will be visible
# when hovering over the player count in the server list.
# This doesn't have any effect when ping passthrough is set to either "description" or "all".
sample-players-in-ping = false

# If not enabled (default is true) player IP addresses will be replaced by <ip address withheld> in logs
enable-player-address-logging = true

[packet-limiter]
# Size of the moving time window in seconds used to calculate average rates.
# A larger window tolerates short bursts while still enforcing the configured limits over time.
interval = 7
# Maximum average number of packets per second a client may send. -1 disables this check.
packets-per-second = -1
# Maximum average number of compressed (on-wire) bytes per second a client may send. -1 disables this check.
bytes-per-second = -1
# Maximum average number of decompressed bytes per second a client may send.
# Protects against compression bomb attacks where small packets expand to excessive sizes after decompression.
# -1 disables this check.
decompressed-bytes-per-second = 5242880

[servers]
$(printf '%b' "$servers_block")

# In what order we should try servers when a player logs in or is kicked from a server.
try = [
$(printf '%b' "$try_lines")
]

[forced-hosts]
# Configure your forced hosts here.
#"lobby.example.com" = [
#    "lobby"
#]
#"factions.example.com" = [
#    "factions"
#]
#"minigames.example.com" = [
#    "minigames"
#]

[advanced]
# How large a Minecraft packet has to be before we compress it. Setting this to zero will
# compress all packets, and setting it to -1 will disable compression entirely.
compression-threshold = 256

# How much compression should be done (from 0-9). The default is -1, which uses the
# default level of 6.
compression-level = -1

# How fast (in milliseconds) are clients allowed to connect after the last connection? By
# default, this is three seconds. Disable this by setting this to 0.
login-ratelimit = 3000

# Specify a custom timeout for connection timeouts here. The default is five seconds.
connection-timeout = 5000

# Specify a read timeout for connections here. The default is 30 seconds.
read-timeout = 30000

# Enables compatibility with HAProxy's PROXY protocol. If you don't know what this is for, then
# don't enable it.
haproxy-protocol = false

# Enables TCP fast open support on the proxy. Requires the proxy to run on Linux.
tcp-fast-open = false

# Enables BungeeCord plugin messaging channel support on Velocity.
bungee-plugin-message-channel = true

# Shows ping requests to the proxy from clients.
show-ping-requests = false

# By default, Velocity will attempt to gracefully handle situations where the user unexpectedly
# loses connection to the server without an explicit disconnect message by attempting to fall the
# user back, except in the case of read timeouts. BungeeCord will disconnect the user instead. You
# can disable this setting to use the BungeeCord behavior.
failover-on-unexpected-server-disconnect = true

# Declares the proxy commands to 1.13+ clients.
announce-proxy-commands = true

# Enables the logging of commands
log-command-executions = false

# Enables logging of player connections when connecting to the proxy, switching servers
# and disconnecting from the proxy.
log-player-connections = true

# Allows players transferred from other hosts via the
# Transfer packet (Minecraft 1.20.5) to be received.
accepts-transfers = false

# Enables support for SO_REUSEPORT. This may help the proxy scale better on multicore systems
# with a lot of incoming connections, and provide better CPU utilization than the existing
# strategy of having a single thread accepting connections and distributing them to worker
# threads. Disabled by default. Requires Linux or macOS.
enable-reuse-port = false

# How fast (in milliseconds) are clients allowed to send commands after the last command
# By default this is 50ms (20 commands per second)
command-rate-limit = 50

# Should we forward commands to the backend upon being rate limited?
# This will forward the command to the server instead of processing it on the proxy.
# Since most server implementations have a rate limit, this will prevent the player
# from being able to send excessive commands to the server.
forward-commands-if-rate-limited = true

# How many commands are allowed to be sent after the rate limit is hit before the player is kicked?
# Setting this to 0 or lower will disable this feature.
kick-after-rate-limited-commands = 0

# How fast (in milliseconds) are clients allowed to send tab completions after the last tab completion
tab-complete-rate-limit = 10

# How many tab completions are allowed to be sent after the rate limit is hit before the player is kicked?
# Setting this to 0 or lower will disable this feature.
kick-after-rate-limited-tab-completes = 0

[query]
# Whether to enable responding to GameSpy 4 query responses or not.
enabled = false

# If query is enabled, on what port should the query protocol listen on?
port = 25565

# This is the map name that is reported to the query services.
map = "Velocity"

# Whether plugins should be shown in query response by default or not
show-plugins = false
EOF
fi

#Plugin installation
if [ ! -f ./plugins ]; then
    mkdir -p ./plugins
fi
rm -f ./plugins/*.jar

plugin_ids="${MODRINTH_PROJECTS:-$PROJECT_ID}"

if [ -n "$plugin_ids" ]; then
    IFS=',' read -r -a ids <<< "$plugin_ids"
    for project_id in "${ids[@]}"; do
        project_id="$(echo "$project_id" | xargs)"
        [ -z "$project_id" ] && continue

        echo "Checking Modrinth plugin: $project_id"
        loaders=$(printf '["velocity"]' | jq -sRr @uri)
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
        #echo "plugin URL: $pluginurl, filename: $filename" #Debuging
        curl -fsSL "$pluginurl" -o "plugins/$filename"
    done
else
    echo "No Modrinth plugin IDs provided"
fi

RAM=${MC_RAM:-2}
exec java -Xmx${RAM}M -Xms256M -jar velocity.jar nogui
#exec java -Xms 512M -Xmx${RAM}G -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:MaxInlineLevel=15 -jar velocity.jar nogui
