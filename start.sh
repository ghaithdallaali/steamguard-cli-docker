#!/bin/bash
set -e

# Ensure config directory has correct permissions
CONFIG_DIR="/root/.config/steamguard-cli"
if [ ! -d "$CONFIG_DIR/maFiles" ]; then
    mkdir -p "$CONFIG_DIR/maFiles" || true
    echo "Created maFiles directory at $CONFIG_DIR/maFiles"
fi

# Print helpful information
echo "==============================================="
echo "SteamGuard CLI is running!"
echo "Web UI available at: http://YOUR_IP:8080"
echo ""
echo "Your SteamGuard configuration should be mounted at:"
echo "$CONFIG_DIR"
echo ""
echo "Place your .maFile files in:"
echo "$CONFIG_DIR/maFiles/"
echo "==============================================="

# Start the web UI in the foreground as PID 1
cd /app/webui
echo "Starting web UI on port 8080..."
exec gunicorn --bind 0.0.0.0:8080 app:app