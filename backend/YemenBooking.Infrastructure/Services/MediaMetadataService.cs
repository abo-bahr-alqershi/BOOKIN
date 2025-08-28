using System;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Interfaces.Services;

namespace YemenBooking.Infrastructure.Services
{
    /// <summary>
    /// خدمة استخراج بيانات الوسائط باستخدام ffprobe إن توفر، أو محاولات احتياطية بسيطة
    /// Media metadata service using ffprobe when available
    /// </summary>
    public class MediaMetadataService : IMediaMetadataService
    {
        private readonly ILogger<MediaMetadataService> _logger;
        private readonly string _ffprobePath;

        public MediaMetadataService(ILogger<MediaMetadataService> logger)
        {
            _logger = logger;
            // Allow overriding ffprobe path via environment variable (FFPROBE_PATH), fallback to PATH
            _ffprobePath = Environment.GetEnvironmentVariable("FFPROBE_PATH")?.Trim() ?? "ffprobe";
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

                // Try ffprobe
                var duration = await ProbeWithFfprobeAsync(filePath, cancellationToken);
                if (duration != null && duration > 0) return duration;

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

        private async Task<int?> ProbeWithFfprobeAsync(string filePath, CancellationToken cancellationToken)
        {
            try
            {
                var startInfo = new ProcessStartInfo
                {
                    FileName = _ffprobePath,
                    // Query duration from format, tags and streams to increase chances
                    Arguments = $"-v error -show_entries format=duration:format_tags=duration:stream=duration -of json \"{filePath}\"",
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    UseShellExecute = false,
                    CreateNoWindow = true
                };

                using var process = new Process { StartInfo = startInfo, EnableRaisingEvents = true };
                process.Start();
                var stdout = await process.StandardOutput.ReadToEndAsync();
                var stderr = await process.StandardError.ReadToEndAsync();
                await process.WaitForExitAsync(cancellationToken);

                if (process.ExitCode != 0)
                {
                    _logger.LogDebug("ffprobe exited with code {Code}: {Err}", process.ExitCode, stderr);
                    return null;
                }

                using var doc = JsonDocument.Parse(stdout);
                // format.duration
                if (doc.RootElement.TryGetProperty("format", out var format))
                {
                    if (format.TryGetProperty("duration", out var durationEl))
                    {
                        var d = ParseDurationValue(durationEl);
                        if (d != null) return d;
                    }
                    // format.tags.duration (may be HH:MM:SS.ms)
                    if (format.TryGetProperty("tags", out var tags) && tags.ValueKind == JsonValueKind.Object)
                    {
                        if (tags.TryGetProperty("duration", out var tagDur))
                        {
                            var d = ParseDurationValue(tagDur);
                            if (d != null) return d;
                        }
                        // Some files store DURATION in uppercase
                        if (tags.TryGetProperty("DURATION", out var tagDur2))
                        {
                            var d = ParseDurationValue(tagDur2);
                            if (d != null) return d;
                        }
                    }
                }

                // streams[i].duration
                if (doc.RootElement.TryGetProperty("streams", out var streams) && streams.ValueKind == JsonValueKind.Array)
                {
                    foreach (var s in streams.EnumerateArray())
                    {
                        if (s.TryGetProperty("duration", out var sd))
                        {
                            var d = ParseDurationValue(sd);
                            if (d != null) return d;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogDebug(ex, "Error running ffprobe");
            }
            return null;
        }

        private static int? ParseDurationValue(JsonElement el)
        {
            try
            {
                if (el.ValueKind == JsonValueKind.Number)
                {
                    if (el.TryGetDouble(out var secondsNum))
                        return (int)Math.Round(secondsNum);
                }
                else if (el.ValueKind == JsonValueKind.String)
                {
                    var s = el.GetString();
                    if (string.IsNullOrWhiteSpace(s)) return null;
                    // Numeric string
                    if (double.TryParse(s, NumberStyles.Any, CultureInfo.InvariantCulture, out var seconds))
                        return (int)Math.Round(seconds);

                    // Try HH:MM:SS(.ms) format
                    if (TimeSpanTryParseFlexible(s, out var ts))
                        return (int)Math.Round(ts.TotalSeconds);
                }
            }
            catch
            {
                // ignore
            }
            return null;
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
