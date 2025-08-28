using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations
{
	public class SectionConfiguration : IEntityTypeConfiguration<Section>
	{
		public void Configure(EntityTypeBuilder<Section> builder)
		{
			builder.ToTable("Sections");
			builder.HasKey(s => s.Id);
			builder.Property(s => s.Type).IsRequired();
			builder.Property(s => s.DisplayOrder).IsRequired();
			builder.Property(s => s.Target).IsRequired();

			builder.HasMany(s => s.Items)
				.WithOne(i => i.Section)
				.HasForeignKey(i => i.SectionId)
				.OnDelete(DeleteBehavior.Cascade);
		}
	}
}