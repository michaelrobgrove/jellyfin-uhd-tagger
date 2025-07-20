# Jellyfin UHD Tagger Plugin

Automatically detect and tag 4K/UHD movies and TV shows in Jellyfin with visual overlays on poster images.

## Features

- 🎯 **Automatic Detection**: Detects 4K content based on resolution and filename patterns
- 🏷️ **Smart Tagging**: Adds "4K" and "UHD" tags to metadata
- 🖼️ **Image Overlays**: Creates badged poster images with 4K overlay
- ⚙️ **Configurable**: Customizable badge text, detection settings, and behavior
- 🚀 **Real-time**: Processes new content automatically as it's added

## Detection Methods

The plugin identifies 4K content using multiple methods:

1. **Video Resolution**: Checks if width ≥ 3840px or height ≥ 2160px
2. **Filename Patterns**: Looks for keywords like "4K", "UHD", "2160p", etc.
3. **Metadata Analysis**: Examines video stream properties

## Installation

### Option 1: Quick Install (Recommended)

```bash
# Clone the repository
git clone https://github.com/yourusername/jellyfin-uhd-tagger.git
cd jellyfin-uhd-tagger

# Make scripts executable
chmod +x build.sh install.sh

# Build and install
./build.sh
sudo ./install.sh
```

### Option 2: Manual Installation

1. **Install .NET 8 SDK** (if not already installed):
```bash
wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y dotnet-sdk-8.0
```

2. **Build the plugin**:
```bash
dotnet build --configuration Release
```

3. **Install manually**:
```bash
sudo systemctl stop jellyfin
sudo mkdir -p /var/lib/jellyfin/plugins/UHDTagger
sudo cp -r bin/Release/net8.0/* /var/lib/jellyfin/plugins/UHDTagger/
sudo chown -R jellyfin:jellyfin /var/lib/jellyfin/plugins/UHDTagger
sudo systemctl start jellyfin
```

## Configuration

After installation:

1. Open Jellyfin web interface
2. Go to **Dashboard** > **Plugins**
3. Find **UHD Tagger** in the plugin list
4. Click to configure:
   - **Badge Text**: Customize the overlay text (default: "4K")
   - **Auto Tagging**: Enable/disable automatic tagging
   - **Image Overlays**: Enable/disable poster overlays
   - **Resolution Thresholds**: Set minimum width/height for 4K detection

## How It Works

### Automatic Processing
- The plugin monitors your Jellyfin library for new or updated content
- When video content is added/updated, it analyzes the file
- If 4K content is detected, it:
  1. Adds metadata tags ("4K", "UHD")
  2. Creates a new poster image with overlay badge
  3. Updates the item to use the badged poster

### Badge Creation
- The plugin uses SkiaSharp to create high-quality overlay badges
- Badges are positioned in the top-right corner by default
- The original poster is preserved (new file created with "-4K" suffix)
- Badges are semi-transparent with rounded corners for professional appearance

## File Structure

```
jellyfin-uhd-tagger/
├── Jellyfin.Plugin.UHDTagger.csproj
├── Plugin.cs
├── UHDTaggerPlugin.cs
├── Configuration/
│   └── PluginConfiguration.cs
├── build.sh
├── install.sh
└── README.md
```

## Troubleshooting

### Plugin Not Appearing
- Check Jellyfin logs: `sudo journalctl -u jellyfin -f`
- Verify plugin files are in: `/var/lib/jellyfin/plugins/UHDTagger/`
- Ensure correct permissions: `sudo chown -R jellyfin:jellyfin /var/lib/jellyfin/plugins/`

### Build Errors
- Ensure .NET 8 SDK is installed: `dotnet --version`
- Check for missing dependencies: `sudo apt-get install -y build-essential`

### Permission Issues
- Run installation with sudo: `sudo ./install.sh`
- Check Jellyfin service user: `ps aux | grep jellyfin`

## Uninstallation

```bash
sudo systemctl stop jellyfin
sudo rm -rf /var/lib/jellyfin/plugins/UHDTagger
sudo systemctl start jellyfin
```

## Development

### Building from Source
```bash
git clone https://github.com/yourusername/jellyfin-uhd-tagger.git
cd jellyfin-uhd-tagger
dotnet build --configuration Debug
```

### Testing
```bash
dotnet test
```

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes and test
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

- **Issues**: Report bugs and feature requests on GitHub
- **Jellyfin Forum**: Post questions in the plugins section
- **Documentation**: Check Jellyfin plugin development docs

## Changelog

### v1.0.0
- Initial release
- Automatic 4K detection and tagging
- Image overlay generation
- Configurable settings

---

**Note**: This plugin is community-developed and not officially supported by Jellyfin. Use at your own risk and always backup your Jellyfin database before installing plugins.