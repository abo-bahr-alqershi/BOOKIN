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

                // جرّب عدة نقاط زمنية لاستخراج إطار صالح (لبعض الفيديوهات القصيرة قد تفشل ثانية 1)
                var probeOffsets = new[] { 0.1, 1.0, 3.0 };
                foreach (var seconds in probeOffsets)
                {
                    var thumb = TryGenerateAtOffset(videoFilePath, seconds);
                    if (thumb != null && thumb.Length > 0)
                    {
                        return Task.FromResult<byte[]?>(thumb);
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

        private byte[]? TryGenerateAtOffset(string videoFilePath, double seconds)
        {
            try
            {
                var tempJpg = Path.Combine(Path.GetTempPath(), $"thumb_{Guid.NewGuid():N}.jpg");
                // ضع -ss قبل -i للـ fast-seek. استخدم دقة موثوقة للقيم الصغيرة
                var ts = TimeSpan.FromSeconds(seconds);
                var hh = ts.Hours.ToString().PadLeft(2, '0');
                var mm = ts.Minutes.ToString().PadLeft(2, '0');
                var ss = ts.Seconds.ToString().PadLeft(2, '0');
                var ms = ts.Milliseconds.ToString().PadLeft(3, '0');
                var offset = $"{hh}:{mm}:{ss}.{ms}";
                var args = $"-y -ss {offset} -i \"{videoFilePath}\" -frames:v 1 -q:v 2 \"{tempJpg}\"";
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
                if (proc.ExitCode != 0 || !File.Exists(tempJpg))
                {
                    var err = proc.StandardError.ReadToEnd();
                    _logger.LogDebug("ffmpeg failed at {Offset}s: {Err}", seconds, err);
                    return null;
                }
                var bytes = File.ReadAllBytes(tempJpg);
                try { File.Delete(tempJpg); } catch { /* ignore */ }
                return bytes;
            }
            catch (Exception ex)
            {
                _logger.LogDebug(ex, "ffmpeg thumbnail gen error at {Offset}s", seconds);
                return null;
            }
        }
    }
}

