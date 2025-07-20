using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Jellyfin.Plugin.UHDTagger.Configuration;
using MediaBrowser.Controller.Entities;
using MediaBrowser.Controller.Entities.Movies;
using MediaBrowser.Controller.Entities.TV;
using MediaBrowser.Controller.Library;
using MediaBrowser.Controller.Plugins;
using MediaBrowser.Model.Entities;
using MediaBrowser.Model.IO;
using Microsoft.Extensions.Logging;
using SkiaSharp;

namespace Jellyfin.Plugin.UHDTagger
{
    public class UHDTaggerPlugin : IServerEntryPoint
    {
        private readonly ILibraryManager _libraryManager;
        private readonly ILogger<UHDTaggerPlugin> _logger;
        private readonly IFileSystem _fileSystem;

        public UHDTaggerPlugin(ILibraryManager libraryManager, ILogger<UHDTaggerPlugin> logger, IFileSystem fileSystem)
        {
            _libraryManager = libraryManager;
            _logger = logger;
            _fileSystem = fileSystem;
        }

        public Task RunAsync()
        {
            _libraryManager.ItemAdded += OnItemAdded;
            _libraryManager.ItemUpdated += OnItemUpdated;
            return Task.CompletedTask;
        }

        private async void OnItemAdded(object sender, ItemChangeEventArgs e)
        {
            await ProcessItem(e.Item);
        }

        private async void OnItemUpdated(object sender, ItemChangeEventArgs e)
        {
            await ProcessItem(e.Item);
        }

        private async Task ProcessItem(BaseItem item)
        {
            if (!(item is Movie || item is Episode))
                return;

            try
            {
                var is4K = Is4KContent(item);
                if (is4K)
                {
                    await AddUHDBadge(item);
                    await UpdateItemTags(item);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing item {ItemName}", item.Name);
            }
        }

        private bool Is4KContent(BaseItem item)
        {
            var mediaStreams = item.GetMediaStreams();
            var videoStream = mediaStreams.FirstOrDefault(s => s.Type == MediaStreamType.Video);
            
            if (videoStream != null)
            {
                // Check resolution
                if (videoStream.Width >= 3840 || videoStream.Height >= 2160)
                    return true;
                
                // Check filename patterns
                var fileName = Path.GetFileNameWithoutExtension(item.Path);
                var uhd4KPatterns = new[] { "4K", "UHD", "2160p", "4k", "uhd" };
                
                return uhd4KPatterns.Any(pattern => 
                    fileName.Contains(pattern, StringComparison.OrdinalIgnoreCase));
            }
            
            return false;
        }

        private async Task AddUHDBadge(BaseItem item)
        {
            var primaryImagePath = item.GetImagePath(ImageType.Primary);
            if (string.IsNullOrEmpty(primaryImagePath) || !File.Exists(primaryImagePath))
                return;

            var badgedImagePath = GetBadgedImagePath(primaryImagePath);
            
            if (File.Exists(badgedImagePath))
                return; // Already processed

            await CreateBadgedImage(primaryImagePath, badgedImagePath);
            
            // Update item to use badged image
            item.SetImagePath(ImageType.Primary, badgedImagePath);
        }

        private async Task CreateBadgedImage(string originalImagePath, string outputPath)
        {
            using var originalBitmap = SKBitmap.Decode(originalImagePath);
            using var surface = SKSurface.Create(new SKImageInfo(originalBitmap.Width, originalBitmap.Height));
            var canvas = surface.Canvas;

            // Draw original image
            canvas.DrawBitmap(originalBitmap, 0, 0);

            // Create 4K badge
            var badgeWidth = originalBitmap.Width / 6;
            var badgeHeight = badgeWidth / 3;
            var badgeX = originalBitmap.Width - badgeWidth - 10;
            var badgeY = 10;

            // Badge background
            var badgePaint = new SKPaint
            {
                Color = SKColors.Red.WithAlpha(220),
                IsAntialias = true
            };
            
            var badgeRect = new SKRoundRect(new SKRect(badgeX, badgeY, badgeX + badgeWidth, badgeY + badgeHeight), 8, 8);
            canvas.DrawRoundRect(badgeRect, badgePaint);

            // Badge text
            var textPaint = new SKPaint
            {
                Color = SKColors.White,
                IsAntialias = true,
                TextSize = badgeHeight * 0.6f,
                Typeface = SKTypeface.FromFamilyName("Arial", SKFontStyle.Bold)
            };

            var textBounds = new SKRect();
            textPaint.MeasureText("4K", ref textBounds);
            
            var textX = badgeX + (badgeWidth - textBounds.Width) / 2;
            var textY = badgeY + (badgeHeight - textBounds.Height) / 2 - textBounds.Top;
            
            canvas.DrawText("4K", textX, textY, textPaint);

            // Save image
            using var image = surface.Snapshot();
            using var data = image.Encode(SKEncodedImageFormat.Jpeg, 90);
            using var stream = File.OpenWrite(outputPath);
            data.SaveTo(stream);
        }

        private string GetBadgedImagePath(string originalPath)
        {
            var directory = Path.GetDirectoryName(originalPath);
            var fileName = Path.GetFileNameWithoutExtension(originalPath);
            var extension = Path.GetExtension(originalPath);
            
            return Path.Combine(directory, $"{fileName}_4K{extension}");
        }

        private async Task UpdateItemTags(BaseItem item)
        {
            var tags = item.Tags.ToList();
            
            if (!tags.Contains("4K", StringComparer.OrdinalIgnoreCase))
            {
                tags.Add("4K");
                item.Tags = tags.ToArray();
                
                await item.UpdateToRepositoryAsync(ItemUpdateType.MetadataEdit, CancellationToken.None);
            }
        }

        public void Dispose()
        {
            _libraryManager.ItemAdded -= OnItemAdded;
            _libraryManager.ItemUpdated -= OnItemUpdated;
        }
    }
}