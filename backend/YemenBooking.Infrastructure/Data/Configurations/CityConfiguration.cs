using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations;

/// <summary>
/// تكوين كيان المدينة
/// City entity configuration
/// </summary>
public class CityConfiguration : IEntityTypeConfiguration<City>
{
    public void Configure(EntityTypeBuilder<City> builder)
    {
        builder.ToTable("Cities");

        builder.HasKey(c => c.Name);
        builder.Property(c => c.Name)
               .HasMaxLength(100)
               .IsRequired();
        builder.Property(c => c.Country)
               .HasMaxLength(100)
               .IsRequired();
        builder.Property(c => c.ImagesJson)
               .HasColumnType("NVARCHAR(MAX)")
               .HasDefaultValue("[]");

        builder.HasIndex(c => new { c.Name, c.Country }).IsUnique();
    }
}

