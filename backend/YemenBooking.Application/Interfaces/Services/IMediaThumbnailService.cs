namespace YemenBooking.Application.Interfaces.Services;

/// <summary>
/// خدمة توليد مصغرات للفيديو باستخدام ffmpeg إذا توفر
/// Video thumbnail generation service using ffmpeg when available
/// </summary>
public interface IMediaThumbnailService
{
    /// <summary>
    /// يحاول توليد صورة مصغرة من ملف فيديو محدد ويعيد البايتات أو null عند الفشل
    /// Try to generate a thumbnail image from a given video file and return bytes or null
    /// </summary>
    /// <param name="videoFilePath">المسار الكامل لملف الفيديو</param>
    /// <param name="cancellationToken">رمز الإلغاء</param>
    /// <returns>بايتات JPEG للمصغّرة أو null</returns>
    Task<byte[]?> TryGenerateThumbnailAsync(string videoFilePath, CancellationToken cancellationToken);
}

