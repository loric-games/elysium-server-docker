#!/bin/bash
set -e

# Fix permissions on mounted volume (runs as root)
echo "--- FIXING VOLUME PERMISSIONS ---"
chown -R steam:steam /home/steam/elysium
chmod -R 755 /home/steam/elysium

# Switch to steam user and run the server script
echo "--- SWITCHING TO STEAM USER ---"
exec su steam -c "bash /home/steam/server.sh"
