#!/bin/bash

# Jellyfin UHD Tagger Plugin Release Build Script

set -e

echo "Building Jellyfin UHD Tagger Plugin for Release..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get version from git tag or use default
if git describe --tags --exact-match 2>/dev/null; then
    VERSION=$(git describe --tags --exact-match)
    VERSION_NUM=${VERSION#v} # Remove 'v' prefix
else
    VERSION_NUM="1.0.0"
    echo -e "${YELLOW}Warning: No git tag found, using version $VERSION_NUM${NC}"
fi

echo -e "${BLUE}Building version: $VERSION_NUM${NC}"

# Clean previous builds
rm -rf bin obj dist

# Create directories
mkdir -p dist build

# Update version in project file if needed
if command -v xmlstarlet >/dev/null 2>&1; then
    xmlstarlet ed -L -u "/Project/PropertyGroup/AssemblyVersion" -v "${VERSION_NUM}.0" Jellyfin.Plugin.UHDTagger.csproj
    xmlstarlet ed -L -u "/Project/PropertyGroup/FileVersion" -v "${VERSION_NUM}.0" Jellyfin.Plugin.UHDTagger.csproj
fi

# Update meta.json with current version and timestamp
cat > build/meta.json << EOF
{
  "guid": "12345678-1234-5678-9012-123456789012",
  "name": "UHD Tagger",
  "description": "Automatically detect and tag 4K/UHD movies and TV shows with visual overlays on poster images",
  "overview": "The UHD Tagger plugin automatically identifies 4K/UHD content in your Jellyfin library and adds visual badges to poster images, making it easy to distinguish between different quality versions of your media.",
  "owner": "michaelrobgrove",
  "category": "Metadata",
  "version": "${VERSION_NUM}.0",
  "changelog": "Version ${VERSION_NUM} - Automatic 4K detection and image overlay generation",
  "targetAbi": "10.9.0.0",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

echo -e "${BLUE}Building plugin...${NC}"

# Build the plugin
dotnet build --configuration Release

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Build successful!${NC}"
    
    # Create plugin zip
    cd bin/Release/net8.0
    zip -r ../../../dist/Jellyfin.Plugin.UHDTagger.zip .
    cd ../../../
    
    # Calculate checksum
    cd dist
    CHECKSUM=$(sha256sum Jellyfin.Plugin.UHDTagger.zip | cut -d' ' -f1)
    echo "$CHECKSUM" > checksum.txt
    echo -e "${GREEN}SHA256: $CHECKSUM${NC}"
    cd ..
    
    # Update manifest.json with proper checksum and download URL
    REPO_URL="https://github.com/michaelrobgrove/jellyfin-uhd-tagger"  # Update this!
    cat > manifest.json << EOF
[
  {
    "guid": "12345678-1234-5678-9012-123456789012",
    "name": "UHD Tagger",
    "description": "Automatically detect and tag 4K/UHD movies and TV shows with visual overlays on poster images",
    "overview": "The UHD Tagger plugin automatically identifies 4K/UHD content in your Jellyfin library and adds visual badges to poster images, making it easy to distinguish between different quality versions of your media.",
    "owner": "michaelrobgrove",
    "category": "Metadata",
    "imageUrl": "${REPO_URL}/raw/main/images/logo.png",
    "versions": [
      {
        "version": "${VERSION_NUM}.0",
        "changelog": "Version ${VERSION_NUM} - Automatic 4K detection and image overlay generation",
        "targetAbi": "10.9.0.0",
        "sourceUrl": "${REPO_URL}/releases/download/v${VERSION_NUM}/Jellyfin.Plugin.UHDTagger.zip",
        "checksum": "$CHECKSUM",
        "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
      }
    ]
  }
]
EOF
    
    echo -e "${GREEN}✓ Plugin built successfully!${NC}"
    echo -e "${BLUE}Files created:${NC}"
    echo "  - dist/Jellyfin.Plugin.UHDTagger.zip"
    echo "  - dist/checksum.txt"
    echo "  - manifest.json (updated)"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Commit and push changes to GitHub"
    echo "2. Create a release tag: git tag v${VERSION_NUM} && git push origin v${VERSION_NUM}"
    echo "3. GitHub Actions will automatically create the release"
    echo "4. Users can add your plugin repository: ${REPO_URL}/raw/main/manifest.json"
else
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi
