#!/bin/bash

################################################################################
# Garry's Mod Dedicated Server Manager
# A self-contained script to install, update, and run a GMOD server
################################################################################

set -e

# Configuration
INSTALL_DIR="$HOME/gmodserver"
STEAMCMD_DIR="$HOME/steamcmd"
SERVER_DIR="$INSTALL_DIR/gmod"

# Server Settings
SRCDS_TOKEN=""
SRCDS_PORT="27015"
SRCDS_MAXPLAYERS="16"
SRCDS_GAMEMODE="terrortown"
SRCDS_MAP="ttt_minecraft_b5"
SRCDS_HOSTNAME="LAN Multi-Gamemode Server"
WORKSHOP_COLLECTIONS="3647706876,3647709812,291050771,3647716900"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

################################################################################
# Helper Functions
################################################################################

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_dependencies() {
    log_info "Checking dependencies..."
    
    # Check for required packages
    local missing_deps=()
    
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    if ! command -v tar &> /dev/null; then
        missing_deps+=("tar")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_info "Install with: sudo apt-get install ${missing_deps[*]}"
        exit 1
    fi
    
    # Check for 32-bit libraries (required for Source engine)
    if ! dpkg --print-foreign-architectures | grep -q i386; then
        log_warn "32-bit architecture not enabled. Attempting to enable..."
        sudo dpkg --add-architecture i386
        sudo apt-get update
    fi
}

install_steamcmd() {
    if [ -f "$STEAMCMD_DIR/steamcmd.sh" ]; then
        log_info "SteamCMD already installed"
        return
    fi
    
    log_info "Installing SteamCMD..."
    mkdir -p "$STEAMCMD_DIR"
    cd "$STEAMCMD_DIR"
    
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
    
    log_info "SteamCMD installed successfully"
}

install_update_server() {
    log_info "Installing/Updating GMOD server..."
    
    mkdir -p "$INSTALL_DIR"
    
    # Run SteamCMD to install/update GMOD server
    # Note: force_install_dir must come BEFORE login
    "$STEAMCMD_DIR/steamcmd.sh" \
        +force_install_dir "$SERVER_DIR" \
        +login anonymous \
        +app_update 4020 validate \
        +quit
    
    log_info "GMOD server installation/update complete"
}

create_server_config() {
    log_info "Creating server configuration..."
    
    local cfg_dir="$SERVER_DIR/garrysmod/cfg"
    mkdir -p "$cfg_dir"
    
    cat > "$cfg_dir/server.cfg" << EOF
// Server Name
hostname "$SRCDS_HOSTNAME"

// Server Settings
sv_lan 0
sv_region 1
sv_pure 0

// Network Settings
sv_maxrate 0
sv_minrate 75000
sv_maxupdaterate 66
sv_minupdaterate 10
sv_maxcmdrate 66
sv_mincmdrate 10

// Server Rules
mp_friendlyfire 0
mp_footsteps 1
mp_autoteambalance 0
mp_autokick 0
mp_flashlight 1
mp_falldamage 1

// Sandbox Settings
sbox_maxprops 150
sbox_maxragdolls 5
sbox_maxvehicles 6
sbox_maxeffects 50
sbox_maxdynamite 10
sbox_maxlamps 10
sbox_maxthrusters 10
sbox_maxwheels 10
sbox_maxhoverballs 10
sbox_maxballoons 10
sbox_maxnpcs 10
sbox_maxsents 20
sbox_maxemitters 5
sbox_godmode 0
sbox_noclip 0

// TTT Specific Settings (if using Trouble in Terrorist Town)
ttt_roundtime_minutes 10
ttt_preptime_seconds 30
ttt_posttime_seconds 30

// Workshop
sv_workshop_enabled 1

// Logging
log on
sv_logbans 1
sv_logecho 1
sv_logfile 1
sv_log_onefile 0

// RCON (set a password for remote admin)
// rcon_password "your_password_here"

// Execute ban files
exec banned_user.cfg
exec banned_ip.cfg
EOF
    
    log_info "Server configuration created"
}

create_workshop_file() {
    log_info "Creating workshop collection file..."
    
    local lua_dir="$SERVER_DIR/garrysmod/lua/autorun/server"
    mkdir -p "$lua_dir"
    
    cat > "$lua_dir/workshop.lua" << EOF
-- Workshop Collections
-- Collections are loaded via server startup parameters
-- This file is kept for reference/backup
EOF
    
    log_info "Workshop configuration created"
}

start_server() {
    log_info "Starting GMOD server..."
    
    cd "$SERVER_DIR"
    
    # Start the server with multiple workshop collections
    ./srcds_run -game garrysmod \
        -console \
        -port "$SRCDS_PORT" \
        -maxplayers "$SRCDS_MAXPLAYERS" \
        +gamemode "$SRCDS_GAMEMODE" \
        +map "$SRCDS_MAP" \
        +sv_setsteamaccount "$SRCDS_TOKEN" \
        +host_workshop_collection 3647706876 \
        +host_workshop_collection 3647709812 \
        +host_workshop_collection 291050771 \
        +host_workshop_collection 3647716900 \
        +exec server.cfg
}

stop_server() {
    log_info "Stopping GMOD server..."
    
    local pid=$(pgrep -f "srcds_linux.*garrysmod" || true)
    
    if [ -z "$pid" ]; then
        log_warn "Server is not running"
        return
    fi
    
    kill "$pid"
    log_info "Server stopped (PID: $pid)"
}

status_server() {
    local pid=$(pgrep -f "srcds_linux.*garrysmod" || true)
    
    if [ -z "$pid" ]; then
        log_info "Server is NOT running"
        return 1
    else
        log_info "Server is running (PID: $pid)"
        return 0
    fi
}

monitor_logs() {
    local log_dir="$SERVER_DIR/garrysmod/logs"
    
    if [ ! -d "$log_dir" ]; then
        log_warn "Log directory not found. Server may not have been started yet."
        return
    fi
    
    # Find the most recent log file
    local latest_log=$(ls -t "$log_dir"/L*.log 2>/dev/null | head -n1)
    
    if [ -z "$latest_log" ]; then
        log_warn "No log files found"
        return
    fi
    
    log_info "Monitoring: $latest_log (Ctrl+C to stop)"
    tail -f "$latest_log"
}

show_usage() {
    cat << EOF
Usage: $0 [command]

Commands:
    install     Install SteamCMD and GMOD server
    update      Update GMOD server to latest version
    start       Start the GMOD server
    stop        Stop the GMOD server
    restart     Restart the GMOD server
    status      Check if server is running
    logs        Monitor server logs in real-time
    setup       Complete setup (install + update + configure)
    run         Update and start server (recommended for routine use)

Examples:
    $0 setup    # First-time setup
    $0 run      # Update and start server
    $0 logs     # View server logs
EOF
}

################################################################################
# Main Script Logic
################################################################################

case "${1:-}" in
    install)
        check_dependencies
        install_steamcmd
        log_info "Installation complete"
        ;;
    
    update)
        install_update_server
        create_server_config
        create_workshop_file
        log_info "Update complete"
        ;;
    
    start)
        start_server
        ;;
    
    stop)
        stop_server
        ;;
    
    restart)
        stop_server
        sleep 2
        start_server
        ;;
    
    status)
        status_server
        ;;
    
    logs)
        monitor_logs
        ;;
    
    setup)
        check_dependencies
        install_steamcmd
        install_update_server
        create_server_config
        create_workshop_file
        log_info "Setup complete! Run '$0 start' to start the server"
        ;;
    
    run)
        check_dependencies
        install_steamcmd
        install_update_server
        create_server_config
        create_workshop_file
        start_server
        ;;
    
    *)
        show_usage
        exit 1
        ;;
esac