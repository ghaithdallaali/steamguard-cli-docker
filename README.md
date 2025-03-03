# SteamGuard CLI with Docker & WebUI

This project is based on [steamguard-cli](https://github.com/dyc3/steamguard-cli) by dyc3, with added Docker support and a web interface.

## Modifications

- Added Docker support
- Created a web UI for easy code generation
- Improved deployment for TrueNAS Scale
- Added network connectivity checks

[Original project license applies](LICENSE)

## TrueNAS Scale Installation

To use steamguard-cli on TrueNAS Scale:

1. Create an application with the Container Image `steamguard-cli:latest`

2. Under the Storage Configuration tab:

   - Add a new mount
   - **Host Path**: Select your dataset where maFiles will be stored (e.g., `/mnt/pool/steamguard`)
   - **Mount Path**: Set to `/root/.config/steamguard-cli`
   - Set permissions to Read/Write

3. Under the Networking tab:

   - Add a port mapping from port 8080 (container) to a port of your choice (node)

4. After deployment, place your Steam Guard `.maFile` files in the dataset you selected at:
   `/mnt/pool/steamguard/maFiles/`

5. Access the web interface at `http://YOUR_TRUENAS_IP:YOUR_CHOSEN_PORT`
