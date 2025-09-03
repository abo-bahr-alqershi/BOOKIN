using Microsoft.EntityFrameworkCore.Migrations;

namespace YemenBooking.Infrastructure.Migrations
{
    public partial class AddTempKeyToPropertyImages : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "TempKey",
                table: "PropertyImages",
                type: "NVARCHAR(100)",
                nullable: true,
                comment: "مفتاح مؤقت لرفع الصور قبل الربط");

            migrationBuilder.CreateIndex(
                name: "IX_PropertyImages_TempKey",
                table: "PropertyImages",
                column: "TempKey");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_PropertyImages_TempKey",
                table: "PropertyImages");

            migrationBuilder.DropColumn(
                name: "TempKey",
                table: "PropertyImages");
        }
    }
}
