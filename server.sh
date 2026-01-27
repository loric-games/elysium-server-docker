#!/bin/bash

# Apply default values for server if not set
SERVER_NAME=${SERVER_NAME:-New\ Elysium\ Server}
SERVER_ADDR=${SERVER_ADDR:-0.0.0.0}
SERVER_PORT=${SERVER_PORT:-27015}
SERVER_DATA=${SERVER_DATA:-./GameData/}
SERVER_WORLD=${SERVER_WORLD:-./world/}
SERVER_LOGS=${SERVER_LOGS:-./logs/}
SERVER_PASSWORD=${SERVER_PASSWORD:-secret}
SERVER_SAVE_FREQUENCY=${SERVER_SAVE_FREQUENCY:-5}
SERVER_PROFILE_ENABLED=${SERVER_PROFILE_ENABLED:-false}
SERVER_BACKUPS_ENABLED=${SERVER_BACKUPS_ENABLED:-true}
SERVER_BACKUPS_FREQUENCY=${SERVER_BACKUPS_FREQUENCY:-30}
SERVER_MAX_BACKUPS=${SERVER_MAX_BACKUPS:-5}
STEAM_CHANNEL=${STEAM_CHANNEL:-default}

# Update server
/home/steam/steamcmd/steamcmd.sh \
	+force_install_dir /home/steam/elysium/server \
	+app_update 2915100 -beta ${STEAM_CHANNEL}\
	+exit

# Create the JSON config used by the server
jo -p \
	address="${SERVER_ADDR}" \
	port=${SERVER_PORT} \
	name="${SERVER_NAME}" \
	password="${SERVER_PASSWORD}" \
	gameDataDir="${SERVER_DATA}" \
	worldDataDir="${SERVER_WORLD}" \
	logsDir="${SERVER_LOGS}" \
	enableProfiling=${SERVER_PROFILE_ENABLED} \
	saveFreqMins=${SERVER_SAVE_FREQUENCY} \
	backupsEnabled=${SERVER_BACKUPS_ENABLED} \
	backupFreqMins=${SERVER_BACKUPS_FREQUENCY} \
	maxBackups=${SERVER_MAX_BACKUPS} \
	> /home/steam/elysium/server/config.json

# Launch server
export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH
export SteamAppId=2644050
if [ ! -e "/home/steam/elysium/server/linux64/libsteam_api.so" ]; then
	ln -s /home/steam/elysium/server/libsteam_api.so /home/steam/elysium/server/linux64/
fi
pushd /home/steam/elysium/server/ > /dev/null
./ElysiumServer --config config.json