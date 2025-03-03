#!/bin/bash
set -e

# Start the web UI in the background
cd /app/webui
gunicorn --bind 0.0.0.0:8080 app:app &
echo "Web UI started on port 8080"

# Keep the container available for CLI commands
exec tail -f /dev/null