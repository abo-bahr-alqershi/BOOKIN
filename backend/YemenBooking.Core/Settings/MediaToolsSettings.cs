namespace YemenBooking.Core.Settings;

/// <summary>
/// إعدادات أدوات الوسائط (MediaInfo)
/// </summary>
public class MediaToolsSettings
{
    /// <summary>
    /// مسار مكتبة MediaInfo الأصلية إن لزم (اختياري)
    /// Optional override path for native MediaInfo library if needed
    /// </summary>
    public string? MediaInfoLibraryPath { get; set; }
}
