# Garry's Mod Dedicated Server

A self-contained bash script to manage a bare metal GMOD server with automatic updates and workshop collection support.

## Features

- ✅ Single script installation and management
- ✅ Automatic SteamCMD installation
- ✅ Server updates with validation
- ✅ Workshop collection support (4 collections included)
- ✅ Trouble in Terrorist Town (TTT) gamemode configured
- ✅ Easy start/stop/restart commands
- ✅ Log monitoring

## Server Configuration

- **Hostname:** LAN Multi-Gamemode Server
- **Port:** 27015
- **Max Players:** 16
- **Gamemode:** Trouble in Terrorist Town (terrortown)
- **Starting Map:** ttt_minecraft_b5
- **Workshop Collection:** 3647706876

## Prerequisites

### System Requirements

- Linux-based operating system (Ubuntu/Debian recommended)
- At least 4GB RAM
- 20GB+ free disk space
- 64-bit system with 32-bit library support

### Required Packages

Before running the script, install the required 32-bit libraries:

```bash
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install -y curl tar lib32gcc-s1 lib32stdc++6 libc6-i386
```

## Installation

### First-Time Setup

1. Download the script and make it executable:

```bash
chmod +x gmod-server.sh
```

2. Run the complete setup (this will take 10-20 minutes):

```bash
./gmod-server.sh setup
```

This will:
- Install SteamCMD
- Download and install the GMOD server
- Create server configuration files
- Set up workshop collections

## Usage

### Starting the Server

**Quick start (recommended):** Update and start in one command:

```bash
./gmod-server.sh run
```

**Manual start:** Start without updating:

```bash
./gmod-server.sh start
```

The server will run in the foreground. To run it in the background, use `screen` or `tmux`:

```bash
screen -S gmod ./gmod-server.sh start
# Press Ctrl+A, then D to detach
```

### Stopping the Server

```bash
./gmod-server.sh stop
```

### Restarting the Server

```bash
./gmod-server.sh restart
```

### Checking Server Status

```bash
./gmod-server.sh status
```

### Monitoring Logs

View logs in real-time:

```bash
./gmod-server.sh logs
```

Press `Ctrl+C` to stop monitoring.

### Updating the Server

Update server files and configuration:

```bash
./gmod-server.sh update
```

## Common Commands Quick Reference

| Command | Description |
|---------|-------------|
| `./gmod-server.sh setup` | First-time installation and setup |
| `./gmod-server.sh run` | Update and start server (recommended) |
| `./gmod-server.sh start` | Start the server |
| `./gmod-server.sh stop` | Stop the server |
| `./gmod-server.sh restart` | Restart the server |
| `./gmod-server.sh status` | Check if server is running |
| `./gmod-server.sh logs` | Monitor server logs |
| `./gmod-server.sh update` | Update server files |

## Configuration

### Changing Server Settings

Edit the configuration variables at the top of `gmod-server.sh`:

```bash
SRCDS_TOKEN=""                    # Steam Game Server Token
SRCDS_PORT="27015"                # Server port
SRCDS_MAXPLAYERS="16"             # Max players
SRCDS_GAMEMODE="terrortown"       # Game mode
SRCDS_MAP="ttt_minecraft_b5"      # Starting map
SRCDS_HOSTNAME="LAN Multi-Gamemode Server"
SRCDS_RCON_PASSWORD="changeme123" # RCON password - CHANGE THIS!
WORKSHOP_COLLECTION="3647706876"  # Workshop collection ID
```

**IMPORTANT:** Change the `SRCDS_RCON_PASSWORD` to something secure before running the server!

### Steam Game Server Token

For public servers, you need a Steam Game Server Account token:

1. Go to: https://steamcommunity.com/dev/managegameservers
2. Create a new token for App ID `4000` (Garry's Mod)
3. Add the token to the `SRCDS_TOKEN` variable in the script

### Advanced Configuration

Server settings can be modified in:
```
~/gmodserver/gmod/garrysmod/cfg/server.cfg
```

### Gamemode-Specific Proximity Chat Settings

The server automatically loads gamemode-specific configs when you change gamemodes. These configs control Enhanced Proximity Voice Chat settings and other gamemode-specific options.

Config files are located at:
```
~/gmodserver/gmod/garrysmod/cfg/
```

**Default gamemode configs created:**
- `terrortown.cfg` - TTT settings (proximity enabled, 20000 radius, dead can't talk)
- `deathrun.cfg` - Deathrun settings (proximity disabled)
- `sandbox.cfg` - Sandbox settings (proximity enabled, 20000 radius, dead can talk)
- `murder.cfg` - Murder settings (proximity enabled, 20000 radius, dead can't talk)
- `jailbreak.cfg` - Jailbreak settings (proximity enabled, 20000 radius, dead can't talk)
- `prophunt.cfg` - Prop Hunt settings (proximity enabled, 20000 radius, dead can't talk)

**To customize proximity chat for a gamemode:**

1. Edit the appropriate config file:
   ```bash
   nano ~/gmodserver/gmod/garrysmod/cfg/terrortown.cfg
   ```

2. Modify these settings:
   ```
   proximity_enabled 1        // 0 or 1 (off or on)
   proximity_radius 3000      // Distance in units
   proximity_mute 0.3         // Volume through walls (0 to 1)
   proximity_deadtalk 0       // Can dead players talk? (0 or 1)
   ```

3. The config will auto-load when you change to that gamemode

**To add a new gamemode config:**

Create a new file named `GAMEMODENAME.cfg` in the cfg directory (e.g., `prophunt.cfg`, `jailbreak.cfg`).

### Remote Server Control (RCON)

You can control the server from your game client or computer using RCON.

**From in-game (while playing on the server):**

1. Open console (` key, usually tilde)
2. Type: `rcon_password YOUR_PASSWORD`
3. Run commands with: `rcon COMMAND`

Examples:
```
rcon_password changeme123
rcon changelevel ttt_67thway_v14
rcon proximity_radius 5000
rcon say Server restarting in 5 minutes!
```

**From your computer (using a separate RCON tool):**

Download an RCON client like:
- **mcrcon** (command line): https://github.com/Tiiffi/mcrcon
- **GCRCON** (GUI): https://github.com/Dreae/GCRCON

Example with mcrcon:
```bash
mcrcon -H YOUR_SERVER_IP -P 27015 -p changeme123 "changelevel gm_construct"
```

**Common RCON commands:**
```
changelevel MAP_NAME          // Change map
gamemode GAMEMODE_NAME        // Change gamemode
say MESSAGE                   // Send server message
ulx map MAP_NAME              // Change map (if using ULX)
status                        // Show connected players
kick PLAYERNAME              // Kick a player
```

## File Locations

- **Server Directory:** `~/gmodserver/gmod/`
- **SteamCMD:** `~/steamcmd/`
- **Server Config:** `~/gmodserver/gmod/garrysmod/cfg/server.cfg`
- **Workshop Config:** `~/gmodserver/gmod/garrysmod/lua/autorun/server/workshop.lua`
- **Logs:** `~/gmodserver/gmod/garrysmod/logs/`

## Troubleshooting

### Server won't start

1. Make sure you have all required 32-bit libraries installed:
```bash
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install -y lib32gcc-s1 lib32stdc++6 libc6-i386
```

2. Verify server files are intact:
```bash
./gmod-server.sh update
```

### Workshop content not downloading

- Ensure `SRCDS_TOKEN` is set for public servers
- Check that workshop collection IDs are correct
- Verify internet connectivity

### Can't connect to server

- Check firewall settings:
```bash
sudo ufw allow 27015/tcp
sudo ufw allow 27015/udp
```

- Verify the server is running:
```bash
./gmod-server.sh status
```

### High CPU usage

- Reduce `SRCDS_MAXPLAYERS` if system is struggling
- Check for problematic workshop addons
- Review server logs for errors

## Running Server on Boot (Optional)

To run the server automatically on system boot, create a systemd service:

```bash
sudo nano /etc/systemd/system/gmod-server.service
```

Add:

```ini
[Unit]
Description=Garry's Mod Server
After=network.target

[Service]
Type=simple
User=YOUR_USERNAME
WorkingDirectory=/home/YOUR_USERNAME
ExecStart=/home/YOUR_USERNAME/gmod-server.sh start
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable gmod-server
sudo systemctl start gmod-server
```

## Support

For GMOD server issues:
- [Facepunch Forums](https://forum.facepunch.com/)
- [GMOD Wiki](https://wiki.facepunch.com/gmod/)

For SteamCMD issues:
- [Valve Developer Wiki](https://developer.valvesoftware.com/wiki/SteamCMD)

## License

This script is provided as-is for managing your own GMOD server. Garry's Mod is a product of Facepunch Studios.