using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Interfaces.Services;
using FFMpegCore;
using FFMpegCore.Pipes;

namespace YemenBooking.Infrastructure.Services
{
    /// <summary>
    /// تنفيذ خدمة توليد مصغرات للفيديو باستخدام ffmpeg
    /// </summary>
    public class MediaThumbnailService : IMediaThumbnailService
    {
        private readonly ILogger<MediaThumbnailService> _logger;
        public MediaThumbnailService(ILogger<MediaThumbnailService> logger)
        {
            _logger = logger;
        }

        public Task<byte[]?> TryGenerateThumbnailAsync(string videoFilePath, CancellationToken cancellationToken)
        {
            try
            {
                if (!File.Exists(videoFilePath)) return Task.FromResult<byte[]?>(null);

                // جرّب عدة نقاط زمنية لاستخراج إطار صالح باستخدام FFMpegCore
                var probeOffsets = new[] { 0.1, 1.0, 3.0 };
                foreach (var seconds in probeOffsets)
                {
                    try
                    {
                        var frame = FFMpeg.Snapshot(videoFilePath, TimeSpan.FromSeconds(seconds));
                        if (frame != null && frame.Length > 0)
                        {
                            return Task.FromResult<byte[]?>(frame);
                        }
                    }
                    catch (Exception ex)
                    {
                        _logger.LogDebug(ex, "FFMpegCore snapshot failed at {Offset}s", seconds);
                    }
                }
                return Task.FromResult<byte[]?>(null);
            }
            catch (Exception ex)
            {
                _logger.LogDebug(ex, "Error generating thumbnail using ffmpeg");
                return Task.FromResult<byte[]?>(null);
            }
        }
    }
}

