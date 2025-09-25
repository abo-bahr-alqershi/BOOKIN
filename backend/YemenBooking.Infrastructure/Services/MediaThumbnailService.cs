using System;
using System.Diagnostics;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Interfaces.Services;

namespace YemenBooking.Infrastructure.Services
{
    /// <summary>
    /// تنفيذ خدمة توليد مصغرات للفيديو باستخدام ffmpeg
    /// </summary>
    public class MediaThumbnailService : IMediaThumbnailService
    {
        private readonly ILogger<MediaThumbnailService> _logger;
        private readonly string _ffmpegPath;

        public MediaThumbnailService(ILogger<MediaThumbnailService> logger)
        {
            _logger = logger;
            _ffmpegPath = Environment.GetEnvironmentVariable("FFMPEG_PATH")?.Trim() ?? "ffmpeg";
        }

        public Task<byte[]?> TryGenerateThumbnailAsync(string videoFilePath, CancellationToken cancellationToken)
        {
            try
            {
                if (!File.Exists(videoFilePath)) return Task.FromResult<byte[]?>(null);

                // استخدم ffmpeg لاستخراج إطار عند ثانية 1 (أغلب الفيديوهات تحتوي إطار مبكر)
                var tempPng = Path.Combine(Path.GetTempPath(), $"thumb_{Guid.NewGuid():N}.jpg");
                var args = $"-y -ss 00:00:01 -i \"{videoFilePath}\" -frames:v 1 -q:v 2 \"{tempPng}\"";
                var psi = new ProcessStartInfo
                {
                    FileName = _ffmpegPath,
                    Arguments = args,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    UseShellExecute = false,
                    CreateNoWindow = true
                };
                using var proc = new Process { StartInfo = psi };
                proc.Start();
                proc.WaitForExit();
                if (proc.ExitCode != 0 || !File.Exists(tempPng))
                {
                    var err = proc.StandardError.ReadToEnd();
                    _logger.LogDebug("ffmpeg failed to generate thumbnail: {Err}", err);
                    return Task.FromResult<byte[]?>(null);
                }
                var bytes = File.ReadAllBytes(tempPng);
                try { File.Delete(tempPng); } catch { /* ignore */ }
                return Task.FromResult<byte[]?>(bytes);
            }
            catch (Exception ex)
            {
                _logger.LogDebug(ex, "Error generating thumbnail using ffmpeg");
                return Task.FromResult<byte[]?>(null);
            }
        }
    }
}

