#!/bin/bash

# Jellyfin UHD Tagger Plugin Build Script for Debian 12

set -e

echo "Building Jellyfin UHD Tagger Plugin..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if .NET SDK is installed
if ! command -v dotnet &> /dev/null; then
    echo -e "${RED}Error: .NET SDK is not installed.${NC}"
    echo -e "${YELLOW}Installing .NET 8 SDK...${NC}"
    
    # Add Microsoft repository
    wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    
    # Install .NET SDK
    sudo apt-get update
    sudo apt-get install -y dotnet-sdk-8.0
    
    echo -e "${GREEN}.NET SDK installed successfully!${NC}"
fi

# Clean previous builds
if [ -d "bin" ]; then
    rm -rf bin
fi

if [ -d "obj" ]; then
    rm -rf obj
fi

echo -e "${BLUE}Building plugin...${NC}"

# Build the plugin
dotnet build --configuration Release

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Build successful!${NC}"
    
    # Create output directory
    mkdir -p output
    
    # Copy built files
    cp -r bin/Release/net8.0/* output/
    
    echo -e "${GREEN}Plugin built successfully!${NC}"
    echo -e "${YELLOW}Files are in the 'output' directory.${NC}"
    echo -e "${BLUE}To install:${NC}"
    echo "1. Stop Jellyfin server"
    echo "2. Copy output files to: /var/lib/jellyfin/plugins/UHDTagger/"
    echo "3. Start Jellyfin server"
    echo "4. Go to Dashboard > Plugins to configure"
else
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi