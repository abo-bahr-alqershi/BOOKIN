using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations
{
	public class SectionItemConfiguration : IEntityTypeConfiguration<SectionItem>
	{
		public void Configure(EntityTypeBuilder<SectionItem> builder)
		{
			builder.ToTable("SectionItems");
			builder.HasKey(si => si.Id);

			builder.Property(si => si.SortOrder).HasDefaultValue(0);

			builder.HasOne(si => si.Property)
				.WithMany(p => p.SectionItems)
				.HasForeignKey(si => si.PropertyId)
				.OnDelete(DeleteBehavior.Cascade);

			builder.HasOne(si => si.Unit)
				.WithMany(u => u.SectionItems)
				.HasForeignKey(si => si.UnitId)
				.OnDelete(DeleteBehavior.Cascade);

			builder.HasIndex(si => new { si.SectionId, si.PropertyId, si.UnitId })
				.IsUnique();
		}
	}
}