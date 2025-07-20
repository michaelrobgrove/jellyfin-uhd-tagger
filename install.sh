#!/bin/bash

# Jellyfin UHD Tagger Plugin Installation Script for Debian 12

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Jellyfin UHD Tagger Plugin Installer${NC}"
echo "====================================="

# Default Jellyfin paths
JELLYFIN_DATA_DIR="/var/lib/jellyfin"
JELLYFIN_PLUGINS_DIR="$JELLYFIN_DATA_DIR/plugins"
PLUGIN_DIR="$JELLYFIN_PLUGINS_DIR/UHDTagger"

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}This script needs to be run with sudo privileges.${NC}"
    echo "Usage: sudo ./install.sh"
    exit 1
fi

# Check if Jellyfin is installed
if ! systemctl list-units --full -all | grep -Fq "jellyfin.service"; then
    echo -e "${RED}Error: Jellyfin service not found. Please install Jellyfin first.${NC}"
    exit 1
fi

# Check if output directory exists
if [ ! -d "output" ]; then
    echo -e "${RED}Error: output directory not found. Please build the plugin first using ./build.sh${NC}"
    exit 1
fi

echo -e "${YELLOW}Stopping Jellyfin service...${NC}"
systemctl stop jellyfin

# Create plugin directory
echo -e "${BLUE}Creating plugin directory...${NC}"
mkdir -p "$PLUGIN_DIR"

# Copy plugin files
echo -e "${BLUE}Installing plugin files...${NC}"
cp -r output/* "$PLUGIN_DIR/"

# Set correct ownership
echo -e "${BLUE}Setting file permissions...${NC}"
chown -R jellyfin:jellyfin "$PLUGIN_DIR"
chmod -R 755 "$PLUGIN_DIR"

# Start Jellyfin service
echo -e "${YELLOW}Starting Jellyfin service...${NC}"
systemctl start jellyfin

# Wait a moment for service to start
sleep 3

# Check if service started successfully
if systemctl is-active --quiet jellyfin; then
    echo -e "${GREEN}✓ Jellyfin service started successfully!${NC}"
else
    echo -e "${RED}✗ Failed to start Jellyfin service. Check logs: journalctl -u jellyfin${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 UHD Tagger Plugin installed successfully!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Open your Jellyfin web interface"
echo "2. Go to Dashboard > Plugins"
echo "3. Find 'UHD Tagger' in the plugin list"
echo "4. Configure the plugin settings as needed"
echo "5. The plugin will automatically start tagging 4K content"
echo ""
echo -e "${YELLOW}Plugin installation path: $PLUGIN_DIR${NC}"
echo -e "${YELLOW}To uninstall: sudo rm -rf $PLUGIN_DIR && sudo systemctl restart jellyfin${NC}"