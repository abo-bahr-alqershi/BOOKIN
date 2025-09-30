using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations
{
    /// <summary>
    /// تكوين كيان إعدادات المستخدم
    /// UserSettings EF configuration
    /// </summary>
    public class UserSettingsConfiguration : IEntityTypeConfiguration<UserSettings>
    {
        public void Configure(EntityTypeBuilder<UserSettings> builder)
        {
            builder.ToTable("UserSettings");
            builder.HasKey(us => us.Id);

            builder.Property(us => us.UserId)
                .IsRequired();

            builder.HasIndex(us => us.UserId)
                .IsUnique();

            builder.Property(us => us.PreferredLanguage)
                .HasMaxLength(10);

            builder.Property(us => us.PreferredCurrency)
                .HasMaxLength(3);

            builder.Property(us => us.TimeZone)
                .HasMaxLength(50);

            // Store AdditionalSettings as JSON if provider supports; fallback to string conversion handled by EF Core
            // No explicit conversion applied here assuming SQL Server can handle JSON nvarchar(max)
        }
    }
}
