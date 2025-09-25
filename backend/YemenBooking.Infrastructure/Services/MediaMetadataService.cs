using System;
using System.Globalization;
using System.IO;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Interfaces.Services;
using MediaInfoLib;

namespace YemenBooking.Infrastructure.Services
{
    /// <summary>
    /// خدمة استخراج بيانات الوسائط باستخدام MediaInfo مع محاولات احتياطية بسيطة لبعض الصيغ
    /// Media metadata service using MediaInfo with simple fallbacks for specific formats
    /// </summary>
    public class MediaMetadataService : IMediaMetadataService
    {
        private readonly ILogger<MediaMetadataService> _logger;
        public MediaMetadataService(ILogger<MediaMetadataService> logger)
        {
            _logger = logger;
        }

        public async Task<int?> TryGetDurationSecondsAsync(string filePath, string? contentType, CancellationToken cancellationToken = default)
        {
            try
            {
                if (!File.Exists(filePath)) return null;
                // Only attempt for audio/video
                var isMedia = (contentType?.StartsWith("audio/", StringComparison.OrdinalIgnoreCase) == true)
                              || (contentType?.StartsWith("video/", StringComparison.OrdinalIgnoreCase) == true)
                              || Regex.IsMatch(Path.GetExtension(filePath), @"\.(mp3|wav|m4a|aac|flac|ogg|mp4|mov|mkv|webm)$", RegexOptions.IgnoreCase);
                if (!isMedia) return null;

                // Use MediaInfo.DotNetWrapper to read duration (milliseconds)
                try
                {
                    using var mi = new MediaInfo();
                    mi.Open(filePath);
                    // Prefer General duration; fallback to Video then Audio
                    var generalDurMs = mi.Get(StreamKind.General, 0, "Duration");
                    var videoDurMs = mi.Get(StreamKind.Video, 0, "Duration");
                    var audioDurMs = mi.Get(StreamKind.Audio, 0, "Duration");

                    if (TryParseMilliseconds(generalDurMs, out var ms) && ms > 0)
                        return (int)Math.Round(ms / 1000.0);
                    if (TryParseMilliseconds(videoDurMs, out ms) && ms > 0)
                        return (int)Math.Round(ms / 1000.0);
                    if (TryParseMilliseconds(audioDurMs, out ms) && ms > 0)
                        return (int)Math.Round(ms / 1000.0);
                }
                catch (Exception ex)
                {
                    _logger.LogDebug(ex, "MediaInfo duration extraction failed");
                }

                // Fallbacks: lightweight parsers for specific formats (WAV)
                var ext = Path.GetExtension(filePath).ToLowerInvariant();
                if (ext == ".wav" || string.Equals(contentType, "audio/wav", StringComparison.OrdinalIgnoreCase) || string.Equals(contentType, "audio/x-wav", StringComparison.OrdinalIgnoreCase))
                {
                    var wavDur = TryGetWavDuration(filePath);
                    if (wavDur != null && wavDur > 0) return wavDur;
                }

                return null;
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to extract media duration for {Path}", filePath);
                return null;
            }
        }

        // Parse helpers remain for WAV fallback

        private static bool TryParseMilliseconds(string? value, out long milliseconds)
        {
            milliseconds = 0;
            if (string.IsNullOrWhiteSpace(value)) return false;
            // MediaInfo returns milliseconds as plain number string
            if (long.TryParse(value.Trim(), NumberStyles.Integer, CultureInfo.InvariantCulture, out var ms))
            {
                milliseconds = ms;
                return true;
            }

            // Sometimes duration may come as formatted string; attempt flexible parse
            if (TimeSpanTryParseFlexible(value, out var ts))
            {
                milliseconds = (long)ts.TotalMilliseconds;
                return true;
            }
            return false;
        }

        private static bool TimeSpanTryParseFlexible(string input, out TimeSpan ts)
        {
            // Accept formats like HH:MM:SS, HH:MM:SS.mmm, MM:SS, MM:SS.mmm
            ts = TimeSpan.Zero;
            input = input.Trim();
            if (TimeSpan.TryParseExact(input, new[] { "c", @"hh\:mm\:ss", @"hh\:mm\:ss\.fff", @"mm\:ss", @"mm\:ss\.fff" }, CultureInfo.InvariantCulture, out ts))
                return true;

            // Some tags may be like "00:03:12.45"
            var m = Regex.Match(input, @"^(\d{1,2}):(\d{2}):(\d{2})(?:\.(\d{1,3}))?$");
            if (m.Success)
            {
                int h = int.Parse(m.Groups[1].Value);
                int mi = int.Parse(m.Groups[2].Value);
                int se = int.Parse(m.Groups[3].Value);
                int ms = m.Groups[4].Success ? int.Parse(m.Groups[4].Value) : 0;
                ts = new TimeSpan(0, h, mi, se, ms);
                return true;
            }
            return false;
        }

        private static int? TryGetWavDuration(string filePath)
        {
            try
            {
                using var fs = new FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.Read);
                using var br = new BinaryReader(fs);

                // RIFF header
                var riff = new string(br.ReadChars(4));
                if (!string.Equals(riff, "RIFF", StringComparison.Ordinal)) return null;
                br.ReadInt32(); // chunk size
                var wave = new string(br.ReadChars(4));
                if (!string.Equals(wave, "WAVE", StringComparison.Ordinal)) return null;

                int? byteRate = null;
                int? dataSize = null;

                while (br.BaseStream.Position + 8 <= br.BaseStream.Length)
                {
                    var chunkId = new string(br.ReadChars(4));
                    int chunkSize = br.ReadInt32();

                    if (chunkId == "fmt ")
                    {
                        // AudioFormat(2) + NumChannels(2) + SampleRate(4) + ByteRate(4) + BlockAlign(2) + BitsPerSample(2) ...
                        if (chunkSize >= 16)
                        {
                            br.ReadInt16(); // audio format
                            br.ReadInt16(); // channels
                            br.ReadInt32(); // sample rate
                            byteRate = br.ReadInt32();
                            // skip the rest of fmt chunk
                            br.BaseStream.Seek(chunkSize - 12, SeekOrigin.Current);
                        }
                        else
                        {
                            br.BaseStream.Seek(chunkSize, SeekOrigin.Current);
                        }
                    }
                    else if (chunkId == "data")
                    {
                        dataSize = chunkSize;
                        // No need to advance further, but move pointer to end of chunk
                        br.BaseStream.Seek(chunkSize, SeekOrigin.Current);
                    }
                    else
                    {
                        // Skip other chunks
                        br.BaseStream.Seek(chunkSize, SeekOrigin.Current);
                    }

                    if (dataSize.HasValue && byteRate.HasValue)
                    {
                        if (byteRate.Value > 0)
                        {
                            var seconds = (double)dataSize.Value / byteRate.Value;
                            return (int)Math.Round(seconds);
                        }
                        break;
                    }
                }
            }
            catch
            {
                // ignore
            }
            return null;
        }
    }
}
