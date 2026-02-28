#!/usr/bin/env bash
set -euo pipefail

# install-claude-desktop.sh — Install Claude Desktop + MCP servers on Kali/Debian/Ubuntu
# Author: SkyzFallin (https://github.com/SkyzFallin)
# Usage: sudo ./install-claude-desktop.sh
#
# Sources:
#   https://claude.ai/download
#   https://www.kali.org/tools/mcp-kali-server/

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (use sudo)." >&2
    exit 1
fi

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
if [[ -z "$REAL_HOME" || ! -d "$REAL_HOME" ]]; then
    echo "Could not determine a valid home directory for user '$REAL_USER'." >&2
    exit 1
fi

if [[ "$REAL_USER" == "root" ]]; then
    echo "Refusing to configure Claude Desktop for root. Run with sudo from your regular user account." >&2
    exit 1
fi

CONFIG_DIR="$REAL_HOME/.config/Claude"
CONFIG_FILE="$CONFIG_DIR/claude_desktop_config.json"
KEYRING_PATH="/usr/share/keyrings/claude-desktop.gpg"
REPO_LIST_PATH="/etc/apt/sources.list.d/claude-desktop.list"

echo "[*] Installing required dependencies..."
apt update -qq
apt install -y --no-install-recommends ca-certificates curl gnupg

echo "[*] Adding Claude Desktop GPG key from claude.ai..."
curl -fsSL https://claude.ai/debian/pubkey.gpg \
    | gpg --dearmor -o "$KEYRING_PATH"
chmod 0644 "$KEYRING_PATH"

echo "[*] Adding APT repository..."
echo "deb [signed-by=$KEYRING_PATH arch=amd64,arm64] https://claude.ai/debian/ stable main" \
    > "$REPO_LIST_PATH"
chmod 0644 "$REPO_LIST_PATH"

echo "[*] Updating package lists..."
apt update -qq

echo "[*] Installing claude-desktop and mcp-kali-server..."
apt install -y claude-desktop mcp-kali-server

echo "[*] Configuring MCP servers..."
mkdir -p "$CONFIG_DIR"
TMP_CONFIG_FILE="$(mktemp)"
cat > "$TMP_CONFIG_FILE" << EOF
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "$REAL_HOME"]
    },
    "kali-mcp-server": {
      "command": "python3",
      "args": [
        "/usr/share/mcp-kali-server/mcp_server.py",
        "--server",
        "http://127.0.0.1:5000/"
      ],
      "description": "Kali MCP Server",
      "timeout": 300
    }
  }
}
EOF

python3 -m json.tool "$TMP_CONFIG_FILE" >/dev/null
install -m 0600 -o "$REAL_USER" -g "$REAL_USER" "$TMP_CONFIG_FILE" "$CONFIG_FILE"
rm -f "$TMP_CONFIG_FILE"
chown -R "$REAL_USER:$REAL_USER" "$CONFIG_DIR"

echo "[+] Installation complete."
echo "    To use:"
echo "      1. Start the Kali API server:  kali-server-mcp"
echo "      2. Launch Claude Desktop:      claude-desktop"
