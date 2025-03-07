#!/bin/bash
set -e

# Set environment variables if necessary (could be added for better clarity)
export USERNAME=${USERNAME:-}
export PASSWORD=${PASSWORD:-}

# Check if credentials are set
if [[ -z "$USERNAME" || -z "$PASSWORD" ]]; then
    echo "Error: USERNAME and PASSWORD must be set as environment variables."
    exit 1
fi

# Ensure config directory has correct permissions
CONFIG_DIR="/root/.config/steamguard-cli"
if [ ! -d "$CONFIG_DIR/maFiles" ]; then
    mkdir -p "$CONFIG_DIR/maFiles"
    echo "Created maFiles directory at $CONFIG_DIR/maFiles"
fi

# Start the web UI in the background
cd /app/webui
echo "Starting web UI on port 8080..."
gunicorn --bind 0.0.0.0:8080 app:app &

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

# Keep the container available for CLI commands
exec tail -f /dev/null