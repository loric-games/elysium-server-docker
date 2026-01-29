# Echoes of Elysium Dedicated Server (Docker)

A fully containerized, easy-to-deploy dedicated server for **Echoes of Elysium**. This setup uses **SteamCMD** on a lightweight Ubuntu image to automatically update and launch the server.

It is designed to run on **Linux** and **Windows (via WSL2)**, with built-in fixes for common permission and filesystem issues specific to hosting on Windows.

## Features
- **Auto-Update:** Checks for game updates every time the container starts.
- **Auto-Config:** Generates `config.json` from simple environment variables—no manual JSON editing required.
- **Cross-Platform:** Optimized for Linux and Windows (WSL2).
- **Persistent Data:** Keeps world saves and logs safe on your host machine.
- **Security:** Runs as a non-root user (`steam`) to prevent permission issues.

---

## Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) or Docker Engine.
- **If on Windows:** You must use **WSL2** (Ubuntu/Debian recommended).
  - *Critical:* Clone this repository into your WSL filesystem (e.g., `~/elysium-server`), NOT on a mounted Windows drive (like `D:\`). Running from a Windows mount causes massive performance loss and permission errors.

---

## Quick Start

### 1. Clone the repository
```bash
git clone https://github.com/your-username/elysium-docker.git
cd elysium-docker
```

### 2. Set Permissions (Critical)
The server script must be executable before Docker picks it up.

```bash
chmod +x server.sh
```

**Windows Users:** If you edited the file using a Windows text editor, run this command to remove hidden Windows line endings that crash the server:

```bash
sed -i 's/\r$//' server.sh
```

### 3. Start the Server
```bash
docker-compose up --build
```

The server will download the game files (approx. 5-10GB) on the first run.
Watch the logs for: `Update state (0x6) : "Success"`.

---

## Configuration

You can configure the server by editing the `environment` section in [docker-compose.yml](docker-compose.yml).

| Variable | Default | Description |
|----------|---------|-------------|
| `SERVER_NAME` | `"NaMP Server"` | The name shown in the server browser. |
| `SERVER_PORT` | `33000` | The internal UDP/TCP port. |
| `SERVER_ADDR` | `0.0.0.0` | Listen address. Keep as `0.0.0.0` for Docker. |
| `SERVER_PASSWORD` | `secret` | Password to join. Leave empty for public access. |
| `STEAM_USER` | `anonymous` | Steam username. "anonymous" works for most dedicated servers. |
| `STEAM_PASS` | _(empty)_ | Steam password (required only if not anonymous). |
| `STEAM_CHANNEL` | `public` | Use "public" for stable, "beta" for experimental branches. |
| `SERVER_SAVE_FREQUENCY` | `5` | Autosave interval in minutes. |
| `SERVER_BACKUPS_ENABLED` | `true` | Enables rotating backups. |
| `SERVER_BACKUPS_FREQUENCY` | `30` | Create a backup every N minutes. |
| `SERVER_MAX_BACKUPS` | `5` | Number of backups to keep. |
| `SERVER_PROFILE_ENABLED` | `false` | Debug profiling (Keep false for performance). |
| `TZ` | `America/New_York` | Timezone for server logs. |

---

## Networking: Bridge vs. Host Mode

### Option 1: Bridge Mode (Default - Best for Windows/WSL2)
Uses Docker's internal network. You must map ports manually in [docker-compose.yml](docker-compose.yml).

**Pros:** Safer, standard Docker practice, works reliably on Windows.
**Cons:** Slightly higher latency (negligible for most).

**Setup:** Uncomment the `ports:` section in [docker-compose.yml](docker-compose.yml):
```yaml
ports:
  - "33000:33000/udp" # Game Traffic (UDP is critical for movement/sync)
  - "33001:33001/udp" # RCON/Query Traffic
```

And comment out `network_mode: host`.

### Option 2: Host Mode (Best for Linux Native)
The container shares the host's networking stack directly.

**Pros:** Lowest possible latency (no NAT overhead).
**Cons:** On Windows, this binds to the WSL VM IP, not your LAN IP, making it hard for friends to connect.

**Setup:** In [docker-compose.yml](docker-compose.yml), keep `network_mode: host` uncommented and comment out the `ports` section.

---

## Troubleshooting

### 1. "Permission Denied" or "Unable to open database file"
This happens if the folder permissions get mixed up (usually by running a command as root/sudo previously).

**Fix:** Force the `steam` user (UID 1001) to own the data folder.
```bash
sudo chown -R 1001:1001 ./elysium_data
```

### 2. "Device or resource busy" / Script Crashes
This often happens if you try to modify [server.sh](server.sh) while the container is running, or if Windows Line Endings (CRLF) corrupted the file.

**Fix:**
1. Stop the container: `docker-compose down`
2. Run the sanitizer: `sed -i 's/\r$//' server.sh`
3. Restart: `docker-compose up`

### 3. Server Lag (Windows Users)
Ensure you are running this from inside the **WSL2 Filesystem** (e.g., `/home/username/`), NOT a mounted Windows drive (`/mnt/c/`).

Mounted drives are extremely slow for game servers due to file system translation overhead.

### 4. Updates Failing
If the Steam update gets stuck or times out:
1. Stop the container.
2. Delete the specific lock files or the temporary download folder in `elysium_data`.
3. Restart the container to force a re-validation.

### 5. Server Not Showing in Browser
- Ensure your firewall allows traffic on the server port (default: `33000/udp` and `33001/udp`).
- If using bridge mode, verify port mappings are correct in [docker-compose.yml](docker-compose.yml).
- Check that `SERVER_ADDR` is set to `0.0.0.0` in the environment variables.

---

## File Structure

```
elysium-server/
├── docker-compose.yml    # Main orchestration file
├── dockerfile            # Container image definition
├── server.sh             # Server startup and update script
├── elysium_data/         # Persistent game data (auto-created)
│   ├── server/           # Game files (downloaded by SteamCMD)
│   ├── GameData/         # Server data files
│   ├── world/            # World saves
│   └── logs/             # Server logs
└── README.md             # This file
```

---

## Advanced Usage

### Running in Background (Detached Mode)
```bash
docker-compose up -d
```

### Viewing Logs
```bash
docker logs -f elysium-server
```

### Stopping the Server
```bash
docker-compose down
```

### Rebuilding the Container
If you modify the [dockerfile](dockerfile) or [server.sh](server.sh):
```bash
docker-compose up --build
```

### Manual Backup
The server creates automatic backups based on your configuration, but you can manually backup the world:
```bash
cp -r ./elysium_data/world ./backup-$(date +%Y%m%d-%H%M%S)
```

---

## License
MIT
