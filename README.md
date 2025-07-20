# Jellyfin UHD Tagger Plugin

Automatically detect and tag 4K/UHD movies and TV shows in Jellyfin with visual overlays on poster images.

[![Build Status](https://github.com/yourusername/jellyfin-uhd-tagger/workflows/Build%20Plugin/badge.svg)](https://github.com/yourusername/jellyfin-uhd-tagger/actions)
[![GitHub release](https://img.shields.io/github/release/yourusername/jellyfin-uhd-tagger.svg)](https://github.com/yourusername/jellyfin-uhd-tagger/releases)

## Features

- 🎯 **Automatic Detection**: Detects 4K content based on resolution and filename patterns
- 🏷️ **Smart Tagging**: Adds "4K" and "UHD" tags to metadata
- 🖼️ **Image Overlays**: Creates badged poster images with 4K overlay
- ⚙️ **Configurable**: Customizable badge text, detection settings, and behavior
- 🚀 **Real-time**: Processes new content automatically as it's added
- 📦 **Easy Install**: Install directly from Jellyfin plugin catalog

## Installation

### Method 1: Plugin Catalog (Recommended)

1. Open Jellyfin admin dashboard
2. Go to **Dashboard** > **Plugins** > **Repositories**
3. Add a new repository:
   - **Repository Name**: UHD Tagger
   - **Repository URL**: `https://raw.githubusercontent.com/michaelrobgrove/jellyfin-uhd-tagger/main/manifest.json`
4. Go to **Dashboard** > **Plugins** > **Catalog**
5. Find "UHD Tagger" and click **Install**
6. Restart Jellyfin when prompted

### Method 2: Manual Installation

1. Download the latest `Jellyfin.Plugin.UHDTagger.zip` from [Releases](https://github.com/yourusername/jellyfin-uhd-tagger/releases)
2. Extract to your Jellyfin plugins directory:
   ```bash
   sudo unzip Jellyfin.Plugin.UHDTagger.zip -d /var/lib/jellyfin/plugins/UHDTagger/
   sudo chown -R jellyfin:jellyfin /var/lib/jellyfin/plugins/UHDTagger/
   sudo systemctl restart jellyfin
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
