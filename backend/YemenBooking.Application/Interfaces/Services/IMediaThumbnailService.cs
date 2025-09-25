namespace YemenBooking.Application.Interfaces.Services;

/// <summary>
/// خدمة توليد مصغرات للفيديو باستخدام ffmpeg إذا توفر
/// Video thumbnail generation service using ffmpeg when available
/// </summary>
public interface IMediaThumbnailService
{
    /// <summary>
    /// يحاول توليد صورة مصغرة من ملف فيديو محدد
    /// Try to generate a thumbnail image from a given video file
    /// </summary>
    /// <param name="videoFilePath">المسار الكامل لملف الفيديو</param>
    /// <param name="outputJpegBytes">النتيجة كصورة JPEG في الذاكرة</param>
    /// <param name="cancellationToken">رمز الإلغاء</param>
    /// <returns>True if success, and sets output bytes; otherwise false</returns>
    Task<bool> TryGenerateThumbnailAsync(string videoFilePath, CancellationToken cancellationToken, out byte[]? outputJpegBytes);
}

