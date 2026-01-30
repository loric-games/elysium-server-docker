#!/bin/bash

# 0. Fix Permissions (ensure steam user owns everything)
echo "--- FIXING PERMISSIONS ---"
chown -R steam:steam /home/steam/elysium 2>/dev/null || true
chmod -R 755 /home/steam/elysium 2>/dev/null || true

# 1. Setup Defaults
SERVER_NAME=${SERVER_NAME:-New Elysium Server}
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
STEAM_CHANNEL=${STEAM_CHANNEL:-public}

# 2. Steam Login Logic
if [ -n "$STEAM_USER" ] && [ "$STEAM_USER" != "anonymous" ]; then
    echo "Check: Logging in with user: $STEAM_USER"
    STEAM_LOGIN_CMD="+login $STEAM_USER $STEAM_PASS"
else
    echo "Check: Logging in anonymously"
    STEAM_LOGIN_CMD="+login anonymous"
fi

# 3. Update Server via SteamCMD
echo "--- STARTING STEAM UPDATE ---"
/home/steam/steamcmd/steamcmd.sh \
    +force_install_dir /home/steam/elysium/server \
    $STEAM_LOGIN_CMD \
    +app_update 2915100 -beta ${STEAM_CHANNEL} validate \
    +quit

# 4. Generate Config JSON
echo "--- GENERATING CONFIG ---"
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

# 5. Fix Libraries & Permissions
export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH
export SteamAppId=2644050

if [ ! -e "/home/steam/elysium/server/linux64/libsteam_api.so" ]; then
    mkdir -p /home/steam/elysium/server/linux64
    ln -s /home/steam/elysium/server/libsteam_api.so /home/steam/elysium/server/linux64/
fi

chmod +x /home/steam/elysium/server/ElysiumServer

# 6. Launch
echo "--- STARTING SERVER ---"
cd /home/steam/elysium/server/
./ElysiumServer --config config.json