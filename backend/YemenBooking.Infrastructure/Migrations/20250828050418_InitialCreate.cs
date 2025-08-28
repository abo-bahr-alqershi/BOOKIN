using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace YemenBooking.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Amenities",
                columns: table => new
                {
                    AmenityId = table.Column<Guid>(type: "TEXT", nullable: false),
                    Name = table.Column<string>(type: "TEXT", maxLength: 50, nullable: false),
                    Description = table.Column<string>(type: "TEXT", maxLength: 200, nullable: false),
                    Icon = table.Column<string>(type: "TEXT", nullable: false),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Amenities", x => x.AmenityId);
                });

            migrationBuilder.CreateTable(
                name: "ChatSettings",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    UserId = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف المستخدم"),
                    NotificationsEnabled = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: true, comment: "تنبيهات مفعلة"),
                    SoundEnabled = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: true, comment: "صوت مفعّل"),
                    ShowReadReceipts = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: true, comment: "عرض إيصالات القراءة"),
                    ShowTypingIndicator = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: true, comment: "عرض مؤشر الكتابة"),
                    Theme = table.Column<string>(type: "TEXT", maxLength: 20, nullable: false, comment: "المظهر: light, dark, auto"),
                    FontSize = table.Column<string>(type: "TEXT", maxLength: 10, nullable: false, comment: "حجم الخط: small, medium, large"),
                    AutoDownloadMedia = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false, comment: "التحميل التلقائي للوسائط"),
                    BackupMessages = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false, comment: "نسخ احتياطي للرسائل"),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "TEXT", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ChatSettings", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Cities",
                columns: table => new
                {
                    Name = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    Country = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    ImagesJson = table.Column<string>(type: "TEXT", nullable: false, defaultValue: "[]")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Cities", x => x.Name);
                });

            migrationBuilder.CreateTable(
                name: "Currencies",
                columns: table => new
                {
                    Code = table.Column<string>(type: "TEXT", maxLength: 10, nullable: false),
                    ArabicCode = table.Column<string>(type: "TEXT", maxLength: 10, nullable: false),
                    Name = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    ArabicName = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    IsDefault = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    ExchangeRate = table.Column<decimal>(type: "decimal(18,6)", nullable: true),
                    LastUpdated = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Currencies", x => x.Code);
                });

            migrationBuilder.CreateTable(
                name: "IndexMetadata",
                columns: table => new
                {
                    IndexType = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false, comment: "نوع الفهرس - Index type identifier"),
                    LastUpdateTime = table.Column<DateTime>(type: "TEXT", nullable: false, defaultValueSql: "GETUTCDATE()", comment: "آخر وقت تحديث للفهرس - Last index update time"),
                    TotalRecords = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0, comment: "عدد السجلات في الفهرس - Total records in index"),
                    LastProcessedId = table.Column<Guid>(type: "TEXT", nullable: true, comment: "آخر معرف تم معالجته - Last processed entity ID"),
                    Status = table.Column<string>(type: "TEXT", maxLength: 50, nullable: false, defaultValue: "Active", comment: "حالة الفهرس - Index status"),
                    Version = table.Column<long>(type: "INTEGER", nullable: false, defaultValue: 1L, comment: "رقم الإصدار للتحكم في التزامن - Version for concurrency control"),
                    FileSizeBytes = table.Column<long>(type: "INTEGER", nullable: false, defaultValue: 0L, comment: "حجم ملف الفهرس بالبايت - Index file size in bytes"),
                    OperationsSinceOptimization = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0, comment: "عدد العمليات منذ آخر تحسين - Operations since last optimization"),
                    LastOptimizationTime = table.Column<DateTime>(type: "TEXT", nullable: true, comment: "آخر وقت تحسين - Last optimization time"),
                    Metadata = table.Column<string>(type: "TEXT", maxLength: 2000, nullable: true, comment: "معلومات إضافية بصيغة JSON - Additional metadata in JSON"),
                    LastErrorMessage = table.Column<string>(type: "TEXT", maxLength: 1000, nullable: true, comment: "رسالة الخطأ الأخيرة - Last error message"),
                    RebuildAttempts = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0, comment: "عدد محاولات إعادة البناء - Rebuild attempts count"),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false, defaultValueSql: "GETUTCDATE()", comment: "تاريخ الإنشاء - Creation timestamp"),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false, defaultValueSql: "GETUTCDATE()", comment: "تاريخ آخر تعديل - Last update timestamp")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_IndexMetadata", x => x.IndexType);
                    table.CheckConstraint("CK_IndexMetadata_FileSizeBytes", "[FileSizeBytes] >= 0");
                    table.CheckConstraint("CK_IndexMetadata_RebuildAttempts", "[RebuildAttempts] >= 0");
                    table.CheckConstraint("CK_IndexMetadata_Status", "[Status] IN ('Active', 'Building', 'Error', 'Disabled', 'Optimizing')");
                    table.CheckConstraint("CK_IndexMetadata_TotalRecords", "[TotalRecords] >= 0");
                    table.CheckConstraint("CK_IndexMetadata_Version", "[Version] > 0");
                });

            migrationBuilder.CreateTable(
                name: "PaymentMethods",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    Name = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    NameEn = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "TEXT", maxLength: 500, nullable: true),
                    Type = table.Column<int>(type: "INTEGER", nullable: false),
                    Code = table.Column<string>(type: "TEXT", maxLength: 50, nullable: false),
                    IconUrl = table.Column<string>(type: "TEXT", maxLength: 500, nullable: true),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsAvailableForClients = table.Column<bool>(type: "INTEGER", nullable: false),
                    RequiresVerification = table.Column<bool>(type: "INTEGER", nullable: false),
                    SupportedCurrencies = table.Column<string>(type: "TEXT", maxLength: 1000, nullable: true),
                    SupportedCountries = table.Column<string>(type: "TEXT", maxLength: 2000, nullable: true),
                    MinAmount = table.Column<decimal>(type: "TEXT", nullable: true),
                    MaxAmount = table.Column<decimal>(type: "TEXT", nullable: true),
                    FeePercentage = table.Column<decimal>(type: "TEXT", nullable: true),
                    FixedFee = table.Column<decimal>(type: "TEXT", nullable: true),
                    DisplayOrder = table.Column<int>(type: "INTEGER", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PaymentMethods", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "PropertyTypes",
                columns: table => new
                {
                    TypeId = table.Column<Guid>(type: "TEXT", nullable: false),
                    Name = table.Column<string>(type: "TEXT", maxLength: 50, nullable: false),
                    Description = table.Column<string>(type: "TEXT", maxLength: 500, nullable: false),
                    DefaultAmenities = table.Column<string>(type: "TEXT", nullable: false),
                    Icon = table.Column<string>(type: "TEXT", nullable: false),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PropertyTypes", x => x.TypeId);
                });

            migrationBuilder.CreateTable(
                name: "Roles",
                columns: table => new
                {
                    RoleId = table.Column<Guid>(type: "TEXT", nullable: false),
                    Name = table.Column<string>(type: "TEXT", maxLength: 50, nullable: false),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Roles", x => x.RoleId);
                });

            migrationBuilder.CreateTable(
                name: "SearchLogs",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    UserId = table.Column<Guid>(type: "TEXT", nullable: false),
                    SearchType = table.Column<string>(type: "TEXT", maxLength: 50, nullable: false),
                    CriteriaJson = table.Column<string>(type: "TEXT", nullable: false),
                    ResultCount = table.Column<int>(type: "INTEGER", nullable: false),
                    PageNumber = table.Column<int>(type: "INTEGER", nullable: false),
                    PageSize = table.Column<int>(type: "INTEGER", nullable: false),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "TEXT", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SearchLogs", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Sections",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    Type = table.Column<int>(type: "INTEGER", nullable: false),
                    DisplayOrder = table.Column<int>(type: "INTEGER", nullable: false),
                    Target = table.Column<int>(type: "INTEGER", nullable: false),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "TEXT", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Sections", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    UserId = table.Column<Guid>(type: "TEXT", nullable: false),
                    Name = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    Email = table.Column<string>(type: "TEXT", maxLength: 255, nullable: false),
                    Password = table.Column<string>(type: "TEXT", nullable: false),
                    Phone = table.Column<string>(type: "TEXT", maxLength: 20, nullable: false),
                    ProfileImage = table.Column<string>(type: "TEXT", maxLength: 500, nullable: false),
                    ProfileImageUrl = table.Column<string>(type: "TEXT", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    LastLoginDate = table.Column<DateTime>(type: "datetime", nullable: true, comment: "تاريخ آخر تسجيل دخول"),
                    TotalSpent = table.Column<decimal>(type: "TEXT", nullable: false),
                    LoyaltyTier = table.Column<string>(type: "TEXT", nullable: true),
                    EmailConfirmed = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false, comment: "حالة تأكيد البريد الإلكتروني"),
                    IsEmailVerified = table.Column<bool>(type: "INTEGER", nullable: false),
                    EmailVerifiedAt = table.Column<DateTime>(type: "TEXT", nullable: true),
                    EmailConfirmationToken = table.Column<string>(type: "TEXT", maxLength: 500, nullable: true, comment: "رمز تأكيد البريد الإلكتروني"),
                    EmailConfirmationTokenExpires = table.Column<DateTime>(type: "datetime", nullable: true, comment: "انتهاء صلاحية رمز تأكيد البريد الإلكتروني"),
                    PasswordResetToken = table.Column<string>(type: "TEXT", maxLength: 500, nullable: true, comment: "رمز إعادة تعيين كلمة المرور"),
                    PasswordResetTokenExpires = table.Column<DateTime>(type: "datetime", nullable: true, comment: "انتهاء صلاحية رمز إعادة تعيين كلمة المرور"),
                    SettingsJson = table.Column<string>(type: "TEXT", nullable: false, defaultValue: "{}", comment: "إعدادات المستخدم بصيغة JSON"),
                    FavoritesJson = table.Column<string>(type: "TEXT", nullable: false, defaultValue: "[]", comment: "قائمة مفضلة المستخدم بصيغة JSON"),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "datetime", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.UserId);
                });

            migrationBuilder.CreateTable(
                name: "PropertyTypeAmenities",
                columns: table => new
                {
                    PtaId = table.Column<Guid>(type: "TEXT", nullable: false),
                    PropertyTypeId = table.Column<Guid>(type: "TEXT", nullable: false),
                    AmenityId = table.Column<Guid>(type: "TEXT", nullable: false),
                    IsDefault = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PropertyTypeAmenities", x => x.PtaId);
                    table.ForeignKey(
                        name: "FK_PropertyTypeAmenities_Amenities_AmenityId",
                        column: x => x.AmenityId,
                        principalTable: "Amenities",
                        principalColumn: "AmenityId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_PropertyTypeAmenities_PropertyTypes_PropertyTypeId",
                        column: x => x.PropertyTypeId,
                        principalTable: "PropertyTypes",
                        principalColumn: "TypeId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "UnitTypes",
                columns: table => new
                {
                    UnitTypeId = table.Column<Guid>(type: "TEXT", nullable: false),
                    Description = table.Column<string>(type: "TEXT", nullable: false),
                    DefaultPricingRules = table.Column<string>(type: "TEXT", nullable: false),
                    PropertyTypeId = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف نوع الكيان"),
                    Name = table.Column<string>(type: "TEXT", maxLength: 50, nullable: false, comment: "اسم نوع الوحدة"),
                    MaxCapacity = table.Column<int>(type: "INTEGER", nullable: false, comment: "الحد الأقصى للسعة"),
                    Icon = table.Column<string>(type: "TEXT", nullable: false),
                    IsHasAdults = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsHasChildren = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsMultiDays = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsRequiredToDetermineTheHour = table.Column<bool>(type: "INTEGER", nullable: false),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UnitTypes", x => x.UnitTypeId);
                    table.ForeignKey(
                        name: "FK_UnitTypes_PropertyTypes_PropertyTypeId",
                        column: x => x.PropertyTypeId,
                        principalTable: "PropertyTypes",
                        principalColumn: "TypeId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "AdminActions",
                columns: table => new
                {
                    ActionId = table.Column<Guid>(type: "TEXT", nullable: false),
                    AdminId = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف المدير"),
                    TargetId = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف الهدف"),
                    TargetType = table.Column<int>(type: "INTEGER", maxLength: 100, nullable: false, comment: "نوع الهدف"),
                    ActionType = table.Column<int>(type: "INTEGER", maxLength: 50, nullable: false, comment: "نوع الإجراء"),
                    Timestamp = table.Column<DateTime>(type: "datetime", nullable: false, comment: "وقت الإجراء"),
                    Changes = table.Column<string>(type: "TEXT", nullable: false, comment: "تغييرات الإجراء"),
                    AdminId1 = table.Column<Guid>(type: "TEXT", nullable: false),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AdminActions", x => x.ActionId);
                    table.ForeignKey(
                        name: "FK_AdminActions_Users_AdminId",
                        column: x => x.AdminId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_AdminActions_Users_AdminId1",
                        column: x => x.AdminId1,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AuditLogs",
                columns: table => new
                {
                    AuditLogId = table.Column<Guid>(type: "TEXT", nullable: false),
                    EntityType = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    EntityId = table.Column<Guid>(type: "TEXT", nullable: true),
                    Action = table.Column<int>(type: "INTEGER", nullable: false),
                    OldValues = table.Column<string>(type: "TEXT", nullable: true),
                    NewValues = table.Column<string>(type: "TEXT", nullable: true),
                    PerformedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    Username = table.Column<string>(type: "TEXT", maxLength: 100, nullable: true),
                    IpAddress = table.Column<string>(type: "TEXT", maxLength: 50, nullable: true),
                    UserAgent = table.Column<string>(type: "TEXT", maxLength: 255, nullable: true),
                    Notes = table.Column<string>(type: "TEXT", nullable: true),
                    Metadata = table.Column<string>(type: "TEXT", nullable: true),
                    IsSuccessful = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: true),
                    ErrorMessage = table.Column<string>(type: "TEXT", maxLength: 500, nullable: true),
                    DurationMs = table.Column<long>(type: "INTEGER", nullable: true),
                    SessionId = table.Column<string>(type: "TEXT", maxLength: 100, nullable: true),
                    RequestId = table.Column<string>(type: "TEXT", maxLength: 100, nullable: true),
                    Source = table.Column<string>(type: "TEXT", maxLength: 100, nullable: true),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "datetime", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: true),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AuditLogs", x => x.AuditLogId);
                    table.ForeignKey(
                        name: "FK_AuditLogs_Users_PerformedBy",
                        column: x => x.PerformedBy,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "Notifications",
                columns: table => new
                {
                    NotificationId = table.Column<Guid>(type: "TEXT", nullable: false),
                    Type = table.Column<string>(type: "TEXT", maxLength: 50, nullable: false),
                    Title = table.Column<string>(type: "TEXT", maxLength: 200, nullable: false),
                    Message = table.Column<string>(type: "TEXT", maxLength: 1000, nullable: false),
                    TitleAr = table.Column<string>(type: "TEXT", maxLength: 200, nullable: true),
                    MessageAr = table.Column<string>(type: "TEXT", maxLength: 1000, nullable: true),
                    Priority = table.Column<string>(type: "TEXT", maxLength: 20, nullable: false),
                    Status = table.Column<string>(type: "TEXT", maxLength: 20, nullable: false),
                    RecipientId = table.Column<Guid>(type: "TEXT", nullable: false),
                    SenderId = table.Column<Guid>(type: "TEXT", nullable: true),
                    Data = table.Column<string>(type: "TEXT", nullable: true),
                    Channels = table.Column<string>(type: "TEXT", nullable: false),
                    SentChannels = table.Column<string>(type: "TEXT", nullable: false),
                    IsRead = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    IsDismissed = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    RequiresAction = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    CanDismiss = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: true),
                    ReadAt = table.Column<DateTime>(type: "datetime", nullable: true),
                    DismissedAt = table.Column<DateTime>(type: "datetime", nullable: true),
                    ScheduledFor = table.Column<DateTime>(type: "datetime", nullable: true),
                    ExpiresAt = table.Column<DateTime>(type: "datetime", nullable: true),
                    DeliveredAt = table.Column<DateTime>(type: "datetime", nullable: true),
                    GroupId = table.Column<string>(type: "TEXT", maxLength: 100, nullable: true),
                    BatchId = table.Column<string>(type: "TEXT", maxLength: 100, nullable: true),
                    Icon = table.Column<string>(type: "TEXT", maxLength: 100, nullable: true),
                    Color = table.Column<string>(type: "TEXT", maxLength: 20, nullable: true),
                    ActionUrl = table.Column<string>(type: "TEXT", maxLength: 500, nullable: true),
                    ActionText = table.Column<string>(type: "TEXT", maxLength: 200, nullable: true),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "datetime", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: true),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Notifications", x => x.NotificationId);
                    table.ForeignKey(
                        name: "FK_Notifications_Users_RecipientId",
                        column: x => x.RecipientId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Notifications_Users_SenderId",
                        column: x => x.SenderId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "Properties",
                columns: table => new
                {
                    PropertyId = table.Column<Guid>(type: "TEXT", nullable: false),
                    OwnerId = table.Column<Guid>(type: "TEXT", nullable: false),
                    TypeId = table.Column<Guid>(type: "TEXT", nullable: false),
                    Name = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    ShortDescription = table.Column<string>(type: "TEXT", nullable: true),
                    BasePricePerNight = table.Column<decimal>(type: "TEXT", nullable: false),
                    Address = table.Column<string>(type: "TEXT", maxLength: 500, nullable: false),
                    City = table.Column<string>(type: "TEXT", maxLength: 50, nullable: false),
                    Latitude = table.Column<decimal>(type: "decimal(9,6)", nullable: false),
                    Longitude = table.Column<decimal>(type: "decimal(9,6)", nullable: false),
                    StarRating = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0),
                    Description = table.Column<string>(type: "TEXT", nullable: false),
                    IsApproved = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime", nullable: false),
                    ViewCount = table.Column<int>(type: "INTEGER", nullable: false),
                    BookingCount = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0),
                    AverageRating = table.Column<decimal>(type: "decimal(5,2)", nullable: false, defaultValue: 0m),
                    Currency = table.Column<string>(type: "TEXT", maxLength: 10, nullable: false),
                    IsFeatured = table.Column<bool>(type: "INTEGER", nullable: false),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Properties", x => x.PropertyId);
                    table.ForeignKey(
                        name: "FK_Properties_Cities_City",
                        column: x => x.City,
                        principalTable: "Cities",
                        principalColumn: "Name",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Properties_Currencies_Currency",
                        column: x => x.Currency,
                        principalTable: "Currencies",
                        principalColumn: "Code",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Properties_PropertyTypes_TypeId",
                        column: x => x.TypeId,
                        principalTable: "PropertyTypes",
                        principalColumn: "TypeId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Properties_Users_OwnerId",
                        column: x => x.OwnerId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "UserRoles",
                columns: table => new
                {
                    UserId = table.Column<Guid>(type: "TEXT", nullable: false),
                    RoleId = table.Column<Guid>(type: "TEXT", nullable: false),
                    AssignedAt = table.Column<DateTime>(type: "datetime", nullable: false),
                    UserRoleId = table.Column<Guid>(type: "TEXT", nullable: false),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserRoles", x => new { x.UserId, x.RoleId });
                    table.ForeignKey(
                        name: "FK_UserRoles_Roles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "Roles",
                        principalColumn: "RoleId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_UserRoles_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "FieldGroups",
                columns: table => new
                {
                    GroupId = table.Column<Guid>(type: "TEXT", nullable: false),
                    UnitTypeId = table.Column<Guid>(type: "TEXT", nullable: false),
                    GroupName = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    DisplayName = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "TEXT", maxLength: 500, nullable: false),
                    SortOrder = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0),
                    IsCollapsible = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    IsExpandedByDefault = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: true),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FieldGroups", x => x.GroupId);
                    table.ForeignKey(
                        name: "FK_FieldGroups_UnitTypes_UnitTypeId",
                        column: x => x.UnitTypeId,
                        principalTable: "UnitTypes",
                        principalColumn: "UnitTypeId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "UnitTypeFields",
                columns: table => new
                {
                    FieldId = table.Column<Guid>(type: "TEXT", nullable: false),
                    UnitTypeId = table.Column<Guid>(type: "TEXT", nullable: false),
                    FieldTypeId = table.Column<string>(type: "TEXT", nullable: false),
                    FieldName = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    DisplayName = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "TEXT", maxLength: 500, nullable: false),
                    FieldOptions = table.Column<string>(type: "TEXT", nullable: false),
                    ValidationRules = table.Column<string>(type: "TEXT", nullable: false),
                    IsRequired = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    IsSearchable = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    IsPublic = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    SortOrder = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0),
                    Category = table.Column<string>(type: "TEXT", maxLength: 50, nullable: false),
                    IsForUnits = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    ShowInCards = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    IsPrimaryFilter = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    Priority = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UnitTypeFields", x => x.FieldId);
                    table.ForeignKey(
                        name: "FK_UnitTypeFields_UnitTypes_UnitTypeId",
                        column: x => x.UnitTypeId,
                        principalTable: "UnitTypes",
                        principalColumn: "UnitTypeId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ChatConversations",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    ConversationType = table.Column<string>(type: "TEXT", maxLength: 20, nullable: false, comment: "نوع المحادثة: direct أو group"),
                    Title = table.Column<string>(type: "TEXT", maxLength: 200, nullable: true, comment: "عنوان المحادثة للمجموعات"),
                    Description = table.Column<string>(type: "TEXT", maxLength: 500, nullable: true, comment: "وصف المحادثة"),
                    Avatar = table.Column<string>(type: "TEXT", maxLength: 500, nullable: true, comment: "مسار الصورة الرمزية"),
                    IsArchived = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false, comment: "هل المحادثة مؤرشفة"),
                    IsMuted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false, comment: "هل المحادثة صامتة"),
                    PropertyId = table.Column<Guid>(type: "TEXT", nullable: true, comment: "معرف الفندق المرتبط بالمحادثة"),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "TEXT", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ChatConversations", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ChatConversations_Properties_PropertyId",
                        column: x => x.PropertyId,
                        principalTable: "Properties",
                        principalColumn: "PropertyId",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "PropertyAmenities",
                columns: table => new
                {
                    PaId = table.Column<Guid>(type: "TEXT", nullable: false),
                    PropertyId = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف الكيان"),
                    PtaId = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف مرفق نوع الكيان"),
                    IsAvailable = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: true, comment: "هل المرفق متاح"),
                    ExtraCost_Amount = table.Column<decimal>(type: "TEXT", precision: 18, scale: 2, nullable: false, comment: "مبلغ التكلفة الإضافية"),
                    ExtraCost_Currency = table.Column<string>(type: "TEXT", maxLength: 3, nullable: false, comment: "عملة التكلفة الإضافية"),
                    ExtraCost_ExchangeRate = table.Column<decimal>(type: "TEXT", nullable: false),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PropertyAmenities", x => x.PaId);
                    table.ForeignKey(
                        name: "FK_PropertyAmenities_Properties_PropertyId",
                        column: x => x.PropertyId,
                        principalTable: "Properties",
                        principalColumn: "PropertyId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_PropertyAmenities_PropertyTypeAmenities_PtaId",
                        column: x => x.PtaId,
                        principalTable: "PropertyTypeAmenities",
                        principalColumn: "PtaId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PropertyPolicies",
                columns: table => new
                {
                    PolicyId = table.Column<Guid>(type: "TEXT", nullable: false),
                    PropertyId = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف الكيان"),
                    Type = table.Column<int>(type: "INTEGER", maxLength: 50, nullable: false, comment: "نوع السياسة"),
                    CancellationWindowDays = table.Column<int>(type: "INTEGER", nullable: false),
                    RequireFullPaymentBeforeConfirmation = table.Column<bool>(type: "INTEGER", nullable: false),
                    MinimumDepositPercentage = table.Column<decimal>(type: "TEXT", nullable: false),
                    MinHoursBeforeCheckIn = table.Column<int>(type: "INTEGER", nullable: false),
                    Description = table.Column<string>(type: "TEXT", maxLength: 1000, nullable: false, comment: "وصف السياسة"),
                    Rules = table.Column<string>(type: "TEXT", nullable: false, comment: "قواعد السياسة (JSON)"),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PropertyPolicies", x => x.PolicyId);
                    table.ForeignKey(
                        name: "FK_PropertyPolicies_Properties_PropertyId",
                        column: x => x.PropertyId,
                        principalTable: "Properties",
                        principalColumn: "PropertyId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PropertyServices",
                columns: table => new
                {
                    ServiceId = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف الخدمة الفريد"),
                    PropertyId = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف الكيان"),
                    Name = table.Column<string>(type: "TEXT", maxLength: 200, nullable: false, comment: "اسم الخدمة"),
                    Price_Amount = table.Column<decimal>(type: "TEXT", precision: 18, scale: 2, nullable: false, comment: "مبلغ سعر الخدمة"),
                    Price_Currency = table.Column<string>(type: "TEXT", maxLength: 3, nullable: false, comment: "عملة سعر الخدمة"),
                    Price_ExchangeRate = table.Column<decimal>(type: "TEXT", nullable: false),
                    Icon = table.Column<string>(type: "TEXT", nullable: false),
                    PricingModel = table.Column<int>(type: "INTEGER", nullable: false, comment: "نموذج التسعير"),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "datetime", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PropertyServices", x => x.ServiceId);
                    table.ForeignKey(
                        name: "FK_PropertyServices_Properties_PropertyId",
                        column: x => x.PropertyId,
                        principalTable: "Properties",
                        principalColumn: "PropertyId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Reports",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    ReporterUserId = table.Column<Guid>(type: "TEXT", nullable: false),
                    ReportedUserId = table.Column<Guid>(type: "TEXT", nullable: true),
                    ReportedPropertyId = table.Column<Guid>(type: "TEXT", nullable: true),
                    Reason = table.Column<string>(type: "TEXT", maxLength: 250, nullable: false),
                    Description = table.Column<string>(type: "TEXT", maxLength: 1000, nullable: false),
                    Status = table.Column<string>(type: "TEXT", maxLength: 50, nullable: false),
                    ActionNote = table.Column<string>(type: "TEXT", maxLength: 1000, nullable: false),
                    AdminId = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "TEXT", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Reports", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Reports_Properties_ReportedPropertyId",
                        column: x => x.ReportedPropertyId,
                        principalTable: "Properties",
                        principalColumn: "PropertyId",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_Reports_Users_ReportedUserId",
                        column: x => x.ReportedUserId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_Reports_Users_ReporterUserId",
                        column: x => x.ReporterUserId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Staff",
                columns: table => new
                {
                    StaffId = table.Column<Guid>(type: "TEXT", nullable: false),
                    UserId = table.Column<Guid>(type: "TEXT", nullable: false),
                    PropertyId = table.Column<Guid>(type: "TEXT", nullable: false),
                    Position = table.Column<int>(type: "INTEGER", maxLength: 100, nullable: false, comment: "منصب الموظف"),
                    Permissions = table.Column<string>(type: "TEXT", nullable: false),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Staff", x => x.StaffId);
                    table.ForeignKey(
                        name: "FK_Staff_Properties_PropertyId",
                        column: x => x.PropertyId,
                        principalTable: "Properties",
                        principalColumn: "PropertyId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Staff_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Units",
                columns: table => new
                {
                    UnitId = table.Column<Guid>(type: "TEXT", nullable: false),
                    PropertyId = table.Column<Guid>(type: "TEXT", nullable: false),
                    UnitTypeId = table.Column<Guid>(type: "TEXT", nullable: false),
                    Name = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    BasePrice_Amount = table.Column<decimal>(type: "TEXT", precision: 18, scale: 2, nullable: false, comment: "مبلغ السعر الأساسي"),
                    BasePrice_Currency = table.Column<string>(type: "TEXT", maxLength: 3, nullable: false, comment: "عملة السعر الأساسي"),
                    BasePrice_ExchangeRate = table.Column<decimal>(type: "TEXT", nullable: false),
                    MaxCapacity = table.Column<int>(type: "INTEGER", nullable: false),
                    DiscountPercentage = table.Column<decimal>(type: "TEXT", nullable: false),
                    CustomFeatures = table.Column<string>(type: "TEXT", nullable: false),
                    IsAvailable = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: true),
                    ViewCount = table.Column<int>(type: "INTEGER", nullable: false),
                    BookingCount = table.Column<int>(type: "INTEGER", nullable: false),
                    AdultsCapacity = table.Column<int>(type: "INTEGER", nullable: true),
                    ChildrenCapacity = table.Column<int>(type: "INTEGER", nullable: true),
                    PricingMethod = table.Column<int>(type: "INTEGER", nullable: false, comment: "طريقة حساب السعر"),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Units", x => x.UnitId);
                    table.ForeignKey(
                        name: "FK_Units_Properties_PropertyId",
                        column: x => x.PropertyId,
                        principalTable: "Properties",
                        principalColumn: "PropertyId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Units_UnitTypes_UnitTypeId",
                        column: x => x.UnitTypeId,
                        principalTable: "UnitTypes",
                        principalColumn: "UnitTypeId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "FieldGroupFields",
                columns: table => new
                {
                    FieldId = table.Column<Guid>(type: "TEXT", nullable: false),
                    GroupId = table.Column<Guid>(type: "TEXT", nullable: false),
                    SortOrder = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0),
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FieldGroupFields", x => new { x.FieldId, x.GroupId });
                    table.ForeignKey(
                        name: "FK_FieldGroupFields_FieldGroups_GroupId",
                        column: x => x.GroupId,
                        principalTable: "FieldGroups",
                        principalColumn: "GroupId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_FieldGroupFields_UnitTypeFields_FieldId",
                        column: x => x.FieldId,
                        principalTable: "UnitTypeFields",
                        principalColumn: "FieldId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SearchFilters",
                columns: table => new
                {
                    FilterId = table.Column<Guid>(type: "TEXT", nullable: false),
                    FieldId = table.Column<Guid>(type: "TEXT", nullable: false),
                    FilterType = table.Column<string>(type: "TEXT", maxLength: 50, nullable: false),
                    DisplayName = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    FilterOptions = table.Column<string>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: true),
                    SortOrder = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0),
                    UnitTypeId = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SearchFilters", x => x.FilterId);
                    table.ForeignKey(
                        name: "FK_SearchFilters_UnitTypeFields_FieldId",
                        column: x => x.FieldId,
                        principalTable: "UnitTypeFields",
                        principalColumn: "FieldId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_SearchFilters_UnitTypes_UnitTypeId",
                        column: x => x.UnitTypeId,
                        principalTable: "UnitTypes",
                        principalColumn: "UnitTypeId");
                });

            migrationBuilder.CreateTable(
                name: "ChatConversationParticipant",
                columns: table => new
                {
                    ConversationId = table.Column<Guid>(type: "TEXT", nullable: false),
                    UserId = table.Column<Guid>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ChatConversationParticipant", x => new { x.ConversationId, x.UserId });
                    table.ForeignKey(
                        name: "FK_ChatConversationParticipant_ChatConversations_ConversationId",
                        column: x => x.ConversationId,
                        principalTable: "ChatConversations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ChatConversationParticipant_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ChatMessages",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    ConversationId = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف المحادثة"),
                    SenderId = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف المستخدم المرسل"),
                    ConversationId1 = table.Column<Guid>(type: "TEXT", nullable: true),
                    MessageType = table.Column<string>(type: "TEXT", maxLength: 20, nullable: false, comment: "نوع الرسالة"),
                    Content = table.Column<string>(type: "TEXT", maxLength: 2000, nullable: true, comment: "محتوى الرسالة"),
                    Location = table.Column<string>(type: "TEXT", nullable: true, comment: "بيانات الموقع بصيغة JSON"),
                    ReplyToMessageId = table.Column<Guid>(type: "TEXT", nullable: true, comment: "معرف الرسالة المرد عليها"),
                    Status = table.Column<string>(type: "TEXT", nullable: false),
                    IsEdited = table.Column<bool>(type: "INTEGER", nullable: false),
                    EditedAt = table.Column<DateTime>(type: "TEXT", nullable: true),
                    DeliveredAt = table.Column<DateTime>(type: "TEXT", nullable: true),
                    ReadAt = table.Column<DateTime>(type: "TEXT", nullable: true),
                    ChatConversationId = table.Column<Guid>(type: "TEXT", nullable: false),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "TEXT", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ChatMessages", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ChatMessages_ChatConversations_ConversationId",
                        column: x => x.ConversationId,
                        principalTable: "ChatConversations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ChatMessages_ChatConversations_ConversationId1",
                        column: x => x.ConversationId1,
                        principalTable: "ChatConversations",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_ChatMessages_ChatMessages_ReplyToMessageId",
                        column: x => x.ReplyToMessageId,
                        principalTable: "ChatMessages",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_ChatMessages_Users_SenderId",
                        column: x => x.SenderId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Bookings",
                columns: table => new
                {
                    BookingId = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف الحجز الفريد"),
                    UserId = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف المستخدم"),
                    UnitId = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف الوحدة"),
                    CheckIn = table.Column<DateTime>(type: "datetime", nullable: false, comment: "تاريخ الوصول"),
                    CheckOut = table.Column<DateTime>(type: "datetime", nullable: false, comment: "تاريخ المغادرة"),
                    GuestsCount = table.Column<int>(type: "INTEGER", nullable: false, comment: "عدد الضيوف"),
                    TotalPrice_Amount = table.Column<decimal>(type: "TEXT", precision: 18, scale: 2, nullable: false, comment: "مبلغ السعر الإجمالي"),
                    TotalPrice_Currency = table.Column<string>(type: "TEXT", maxLength: 3, nullable: false, comment: "عملة السعر الإجمالي"),
                    TotalPrice_ExchangeRate = table.Column<decimal>(type: "TEXT", nullable: false),
                    Status = table.Column<int>(type: "INTEGER", maxLength: 50, nullable: false, comment: "حالة الحجز"),
                    BookedAt = table.Column<DateTime>(type: "datetime", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP", comment: "تاريخ الحجز"),
                    BookingSource = table.Column<string>(type: "TEXT", nullable: true),
                    CancellationReason = table.Column<string>(type: "TEXT", nullable: true),
                    IsWalkIn = table.Column<bool>(type: "INTEGER", nullable: false),
                    PlatformCommissionAmount = table.Column<decimal>(type: "TEXT", nullable: false),
                    ActualCheckInDate = table.Column<DateTime>(type: "TEXT", nullable: true),
                    ActualCheckOutDate = table.Column<DateTime>(type: "TEXT", nullable: true),
                    FinalAmount = table.Column<decimal>(type: "TEXT", nullable: false),
                    CustomerRating = table.Column<decimal>(type: "TEXT", nullable: true),
                    CompletionNotes = table.Column<string>(type: "TEXT", nullable: true),
                    Booking_TotalPrice_Currency = table.Column<string>(type: "TEXT", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false, comment: "حالة الحذف الناعم"),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true, comment: "تاريخ الحذف")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Bookings", x => x.BookingId);
                    table.ForeignKey(
                        name: "FK_Bookings_Currencies_Booking_TotalPrice_Currency",
                        column: x => x.Booking_TotalPrice_Currency,
                        principalTable: "Currencies",
                        principalColumn: "Code",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Bookings_Units_UnitId",
                        column: x => x.UnitId,
                        principalTable: "Units",
                        principalColumn: "UnitId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Bookings_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "PricingRules",
                columns: table => new
                {
                    PricingRuleId = table.Column<Guid>(type: "TEXT", nullable: false),
                    UnitId = table.Column<Guid>(type: "TEXT", nullable: false),
                    PriceType = table.Column<string>(type: "TEXT", maxLength: 50, nullable: false),
                    StartDate = table.Column<DateTime>(type: "datetime", nullable: false),
                    EndDate = table.Column<DateTime>(type: "datetime", nullable: false),
                    StartTime = table.Column<TimeSpan>(type: "time", nullable: true),
                    EndTime = table.Column<TimeSpan>(type: "time", nullable: true),
                    PriceAmount = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    PricingTier = table.Column<string>(type: "TEXT", maxLength: 20, nullable: false),
                    PercentageChange = table.Column<decimal>(type: "decimal(5,2)", nullable: true),
                    MinPrice = table.Column<decimal>(type: "decimal(18,2)", nullable: true),
                    MaxPrice = table.Column<decimal>(type: "decimal(18,2)", nullable: true),
                    Description = table.Column<string>(type: "TEXT", maxLength: 500, nullable: true),
                    Currency = table.Column<string>(type: "TEXT", maxLength: 3, nullable: false),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PricingRules", x => x.PricingRuleId);
                    table.ForeignKey(
                        name: "FK_PricingRules_Currencies_Currency",
                        column: x => x.Currency,
                        principalTable: "Currencies",
                        principalColumn: "Code",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_PricingRules_Units_UnitId",
                        column: x => x.UnitId,
                        principalTable: "Units",
                        principalColumn: "UnitId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PropertyImages",
                columns: table => new
                {
                    ImageId = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف الصورة الفريد"),
                    PropertyId = table.Column<Guid>(type: "TEXT", nullable: true, comment: "معرف الكيان"),
                    UnitId = table.Column<Guid>(type: "TEXT", nullable: true),
                    Name = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    Url = table.Column<string>(type: "TEXT", maxLength: 500, nullable: false, comment: "مسار الصورة"),
                    SizeBytes = table.Column<long>(type: "INTEGER", nullable: false),
                    Type = table.Column<string>(type: "TEXT", maxLength: 50, nullable: false),
                    Category = table.Column<int>(type: "INTEGER", nullable: false),
                    Caption = table.Column<string>(type: "TEXT", maxLength: 200, nullable: false),
                    AltText = table.Column<string>(type: "TEXT", maxLength: 200, nullable: false, comment: "وصف الصورة"),
                    Tags = table.Column<string>(type: "TEXT", nullable: false),
                    Sizes = table.Column<string>(type: "TEXT", nullable: false),
                    IsMain = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false, comment: "هل هي الصورة الرئيسية"),
                    SortOrder = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0),
                    Views = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0),
                    Downloads = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0),
                    UploadedAt = table.Column<DateTime>(type: "datetime", nullable: false),
                    DisplayOrder = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0),
                    Status = table.Column<int>(type: "INTEGER", nullable: false),
                    IsMainImage = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false, comment: "حالة الحذف الناعم"),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true, comment: "تاريخ الحذف")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PropertyImages", x => x.ImageId);
                    table.ForeignKey(
                        name: "FK_PropertyImages_Properties_PropertyId",
                        column: x => x.PropertyId,
                        principalTable: "Properties",
                        principalColumn: "PropertyId",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_PropertyImages_Units_UnitId",
                        column: x => x.UnitId,
                        principalTable: "Units",
                        principalColumn: "UnitId",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "SectionItems",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    SectionId = table.Column<Guid>(type: "TEXT", nullable: false),
                    PropertyId = table.Column<Guid>(type: "TEXT", nullable: true),
                    UnitId = table.Column<Guid>(type: "TEXT", nullable: true),
                    SortOrder = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "TEXT", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SectionItems", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SectionItems_Properties_PropertyId",
                        column: x => x.PropertyId,
                        principalTable: "Properties",
                        principalColumn: "PropertyId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_SectionItems_Sections_SectionId",
                        column: x => x.SectionId,
                        principalTable: "Sections",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_SectionItems_Units_UnitId",
                        column: x => x.UnitId,
                        principalTable: "Units",
                        principalColumn: "UnitId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "UnitFieldValues",
                columns: table => new
                {
                    ValueId = table.Column<Guid>(type: "TEXT", nullable: false),
                    UnitId = table.Column<Guid>(type: "TEXT", nullable: false),
                    UnitTypeFieldId = table.Column<Guid>(type: "TEXT", nullable: false),
                    FieldValue = table.Column<string>(type: "text", nullable: false),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UnitFieldValues", x => x.ValueId);
                    table.ForeignKey(
                        name: "FK_UnitFieldValues_UnitTypeFields_UnitTypeFieldId",
                        column: x => x.UnitTypeFieldId,
                        principalTable: "UnitTypeFields",
                        principalColumn: "FieldId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_UnitFieldValues_Units_UnitId",
                        column: x => x.UnitId,
                        principalTable: "Units",
                        principalColumn: "UnitId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ChatAttachments",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    ConversationId = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف المحادثة"),
                    FileName = table.Column<string>(type: "TEXT", maxLength: 200, nullable: false, comment: "اسم الملف الأصلي"),
                    ContentType = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false, comment: "نوع المحتوى"),
                    FileSize = table.Column<long>(type: "INTEGER", nullable: false, comment: "حجم الملف بالبايت"),
                    FilePath = table.Column<string>(type: "TEXT", maxLength: 500, nullable: false, comment: "مسار الملف على الخادم"),
                    ThumbnailUrl = table.Column<string>(type: "TEXT", maxLength: 500, nullable: true, comment: "URL of the thumbnail image (optional)"),
                    Metadata = table.Column<string>(type: "TEXT", nullable: true, comment: "Additional metadata as JSON string (optional)"),
                    DurationSeconds = table.Column<int>(type: "INTEGER", nullable: true, comment: "Attachment duration in seconds (audio/video)"),
                    UploadedBy = table.Column<Guid>(type: "TEXT", nullable: false, comment: "المستخدم الذي رفع الملف"),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    ChatMessageId = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "TEXT", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ChatAttachments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ChatAttachments_ChatConversations_ConversationId",
                        column: x => x.ConversationId,
                        principalTable: "ChatConversations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ChatAttachments_ChatMessages_ChatMessageId",
                        column: x => x.ChatMessageId,
                        principalTable: "ChatMessages",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "MessageReactions",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    MessageId = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف الرسالة"),
                    UserId = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف المستخدم"),
                    ReactionType = table.Column<string>(type: "TEXT", maxLength: 20, nullable: false, comment: "نوع التفاعل"),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "TEXT", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MessageReactions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MessageReactions_ChatMessages_MessageId",
                        column: x => x.MessageId,
                        principalTable: "ChatMessages",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "BookingServices",
                columns: table => new
                {
                    BookingId = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف الحجز"),
                    ServiceId = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف الخدمة"),
                    Quantity = table.Column<int>(type: "INTEGER", nullable: false, comment: "الكمية"),
                    TotalPrice_Amount = table.Column<decimal>(type: "TEXT", precision: 18, scale: 2, nullable: false, comment: "مبلغ السعر الإجمالي للخدمة"),
                    TotalPrice_Currency = table.Column<string>(type: "TEXT", maxLength: 3, nullable: false, comment: "عملة السعر الإجمالي للخدمة"),
                    TotalPrice_ExchangeRate = table.Column<decimal>(type: "TEXT", nullable: false),
                    BookingServiceId = table.Column<Guid>(type: "TEXT", nullable: false),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BookingServices", x => new { x.BookingId, x.ServiceId });
                    table.ForeignKey(
                        name: "FK_BookingServices_Bookings_BookingId",
                        column: x => x.BookingId,
                        principalTable: "Bookings",
                        principalColumn: "BookingId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_BookingServices_PropertyServices_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "PropertyServices",
                        principalColumn: "ServiceId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Payments",
                columns: table => new
                {
                    PaymentId = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف الدفع الفريد"),
                    BookingId = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف الحجز"),
                    Amount_Amount = table.Column<decimal>(type: "TEXT", precision: 18, scale: 2, nullable: false, comment: "مبلغ الدفع"),
                    Amount_Currency = table.Column<string>(type: "TEXT", maxLength: 3, nullable: false, comment: "عملة الدفع"),
                    Amount_ExchangeRate = table.Column<decimal>(type: "TEXT", nullable: false),
                    MethodId = table.Column<Guid>(type: "TEXT", nullable: false),
                    TransactionId = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false, comment: "معرف المعاملة"),
                    Status = table.Column<int>(type: "INTEGER", maxLength: 50, nullable: false, comment: "حالة الدفع"),
                    PaymentDate = table.Column<DateTime>(type: "datetime", nullable: false, comment: "تاريخ الدفع"),
                    GatewayTransactionId = table.Column<string>(type: "TEXT", nullable: false),
                    ProcessedBy = table.Column<Guid>(type: "TEXT", nullable: false),
                    ProcessedAt = table.Column<DateTime>(type: "TEXT", nullable: true),
                    Payment_Amount_Currency = table.Column<string>(type: "TEXT", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false, comment: "حالة الحذف الناعم"),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true, comment: "تاريخ الحذف")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Payments", x => x.PaymentId);
                    table.ForeignKey(
                        name: "FK_Payments_Bookings_BookingId",
                        column: x => x.BookingId,
                        principalTable: "Bookings",
                        principalColumn: "BookingId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Payments_Currencies_Payment_Amount_Currency",
                        column: x => x.Payment_Amount_Currency,
                        principalTable: "Currencies",
                        principalColumn: "Code",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Payments_PaymentMethods_MethodId",
                        column: x => x.MethodId,
                        principalTable: "PaymentMethods",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Reviews",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف التقييم الفريد"),
                    BookingId = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف الحجز"),
                    PropertyId = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف الكيان"),
                    Cleanliness = table.Column<int>(type: "INTEGER", nullable: false, comment: "تقييم النظافة"),
                    Service = table.Column<int>(type: "INTEGER", nullable: false, comment: "تقييم الخدمة"),
                    Location = table.Column<int>(type: "INTEGER", nullable: false, comment: "تقييم الموقع"),
                    Value = table.Column<int>(type: "INTEGER", nullable: false, comment: "تقييم القيمة"),
                    AverageRating = table.Column<decimal>(type: "decimal(5,2)", nullable: false, defaultValue: 0m, comment: "متوسط التقييم"),
                    Comment = table.Column<string>(type: "TEXT", nullable: false, comment: "تعليق التقييم"),
                    CreatedAt = table.Column<DateTime>(type: "datetime", nullable: false, comment: "تاريخ إنشاء التقييم"),
                    ResponseText = table.Column<string>(type: "TEXT", nullable: true),
                    ResponseDate = table.Column<DateTime>(type: "TEXT", nullable: true),
                    IsPendingApproval = table.Column<bool>(type: "INTEGER", nullable: false),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false, comment: "حالة الحذف الناعم"),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true, comment: "تاريخ الحذف")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Reviews", x => x.Id);
                    table.CheckConstraint("CK_Reviews_Cleanliness", "[Cleanliness] >= 1 AND [Cleanliness] <= 5");
                    table.CheckConstraint("CK_Reviews_Location", "[Location] >= 1 AND [Location] <= 5");
                    table.CheckConstraint("CK_Reviews_Service", "[Service] >= 1 AND [Service] <= 5");
                    table.CheckConstraint("CK_Reviews_Value", "[Value] >= 1 AND [Value] <= 5");
                    table.ForeignKey(
                        name: "FK_Reviews_Bookings_BookingId",
                        column: x => x.BookingId,
                        principalTable: "Bookings",
                        principalColumn: "BookingId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Reviews_Properties_PropertyId",
                        column: x => x.PropertyId,
                        principalTable: "Properties",
                        principalColumn: "PropertyId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "UnitAvailability",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    UnitId = table.Column<Guid>(type: "TEXT", nullable: false),
                    StartDate = table.Column<DateTime>(type: "datetime", nullable: false),
                    EndDate = table.Column<DateTime>(type: "datetime", nullable: false),
                    Status = table.Column<string>(type: "TEXT", maxLength: 20, nullable: false),
                    Reason = table.Column<string>(type: "TEXT", maxLength: 50, nullable: true),
                    Notes = table.Column<string>(type: "TEXT", maxLength: 500, nullable: true),
                    BookingId = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UnitAvailability", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UnitAvailability_Bookings_BookingId",
                        column: x => x.BookingId,
                        principalTable: "Bookings",
                        principalColumn: "BookingId",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_UnitAvailability_Units_UnitId",
                        column: x => x.UnitId,
                        principalTable: "Units",
                        principalColumn: "UnitId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ReviewImages",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف الصورة الفريدة"),
                    ReviewId = table.Column<Guid>(type: "TEXT", nullable: false, comment: "معرف التقييم المرتبط"),
                    Name = table.Column<string>(type: "TEXT", maxLength: 200, nullable: false, comment: "اسم الملف"),
                    Url = table.Column<string>(type: "TEXT", maxLength: 500, nullable: false, comment: "مسار الصورة"),
                    SizeBytes = table.Column<long>(type: "INTEGER", nullable: false, comment: "حجم الملف بالبايت"),
                    Type = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false, comment: "نوع المحتوى"),
                    Category = table.Column<int>(type: "INTEGER", nullable: false, comment: "فئة الصورة"),
                    Caption = table.Column<string>(type: "TEXT", maxLength: 200, nullable: false, comment: "تعليق توضيحي للصورة"),
                    AltText = table.Column<string>(type: "TEXT", maxLength: 200, nullable: false, comment: "نص بديل للصورة"),
                    Tags = table.Column<string>(type: "TEXT", nullable: false, comment: "وسوم الصورة"),
                    IsMain = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false, comment: "هل هي الصورة الرئيسية"),
                    DisplayOrder = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0, comment: "ترتيب العرض"),
                    UploadedAt = table.Column<DateTime>(type: "datetime", nullable: false, comment: "تاريخ الرفع"),
                    Status = table.Column<int>(type: "INTEGER", nullable: false, comment: "حالة الموافقة للصورة"),
                    CreatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false, comment: "حالة الحذف الناعم"),
                    DeletedBy = table.Column<Guid>(type: "TEXT", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "TEXT", nullable: true, comment: "تاريخ الحذف")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ReviewImages", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ReviewImages_Reviews_ReviewId",
                        column: x => x.ReviewId,
                        principalTable: "Reviews",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "Amenities",
                columns: new[] { "AmenityId", "CreatedAt", "CreatedBy", "DeletedAt", "DeletedBy", "Description", "Icon", "IsActive", "Name", "UpdatedAt", "UpdatedBy" },
                values: new object[,]
                {
                    { new Guid("11111111-1111-1111-1111-111111111111"), new DateTime(2025, 8, 28, 5, 4, 16, 683, DateTimeKind.Utc).AddTicks(2523), null, null, null, "إنترنت لاسلكي مجاني", "", true, "واي فاي", new DateTime(2025, 8, 28, 5, 4, 16, 683, DateTimeKind.Utc).AddTicks(2524), null },
                    { new Guid("22222222-2222-2222-2222-222222222222"), new DateTime(2025, 8, 28, 5, 4, 16, 683, DateTimeKind.Utc).AddTicks(2541), null, null, null, "مسبح للسباحة", "", true, "مسبح", new DateTime(2025, 8, 28, 5, 4, 16, 683, DateTimeKind.Utc).AddTicks(2542), null },
                    { new Guid("33333333-3333-3333-3333-333333333333"), new DateTime(2025, 8, 28, 5, 4, 16, 683, DateTimeKind.Utc).AddTicks(2547), null, null, null, "صالة رياضية", "", true, "جيم", new DateTime(2025, 8, 28, 5, 4, 16, 683, DateTimeKind.Utc).AddTicks(2548), null },
                    { new Guid("44444444-4444-4444-4444-444444444444"), new DateTime(2025, 8, 28, 5, 4, 16, 683, DateTimeKind.Utc).AddTicks(2553), null, null, null, "خدمة المطعم", "", true, "مطعم", new DateTime(2025, 8, 28, 5, 4, 16, 683, DateTimeKind.Utc).AddTicks(2553), null },
                    { new Guid("55555555-5555-5555-5555-555555555555"), new DateTime(2025, 8, 28, 5, 4, 16, 683, DateTimeKind.Utc).AddTicks(2556), null, null, null, "موقف سيارات مجاني", "", true, "موقف سيارات", new DateTime(2025, 8, 28, 5, 4, 16, 683, DateTimeKind.Utc).AddTicks(2556), null },
                    { new Guid("66666666-6666-6666-6666-666666666666"), new DateTime(2025, 8, 28, 5, 4, 16, 683, DateTimeKind.Utc).AddTicks(2560), null, null, null, "تكييف الهواء", "", true, "تكييف", new DateTime(2025, 8, 28, 5, 4, 16, 683, DateTimeKind.Utc).AddTicks(2560), null },
                    { new Guid("77777777-7777-7777-7777-777777777777"), new DateTime(2025, 8, 28, 5, 4, 16, 683, DateTimeKind.Utc).AddTicks(2563), null, null, null, "تلفزيون بشاشة مسطحة", "", true, "تلفزيون", new DateTime(2025, 8, 28, 5, 4, 16, 683, DateTimeKind.Utc).AddTicks(2565), null },
                    { new Guid("88888888-8888-8888-8888-888888888888"), new DateTime(2025, 8, 28, 5, 4, 16, 683, DateTimeKind.Utc).AddTicks(2568), null, null, null, "وجبة إفطار مجانية", "", true, "إفطار", new DateTime(2025, 8, 28, 5, 4, 16, 683, DateTimeKind.Utc).AddTicks(2569), null }
                });

            migrationBuilder.InsertData(
                table: "Cities",
                columns: new[] { "Name", "Country", "ImagesJson" },
                values: new object[,]
                {
                    { "تعز", "اليمن", "[]" },
                    { "صنعاء", "اليمن", "[]" },
                    { "عدن", "اليمن", "[]" }
                });

            migrationBuilder.InsertData(
                table: "Currencies",
                columns: new[] { "Code", "ArabicCode", "ArabicName", "ExchangeRate", "LastUpdated", "Name" },
                values: new object[] { "USD", "دولار", "الدولار الأمريكي", 0.004m, new DateTime(2025, 8, 28, 5, 4, 16, 827, DateTimeKind.Utc).AddTicks(1331), "US Dollar" });

            migrationBuilder.InsertData(
                table: "Currencies",
                columns: new[] { "Code", "ArabicCode", "ArabicName", "ExchangeRate", "IsDefault", "LastUpdated", "Name" },
                values: new object[] { "YER", "ريال", "الريال اليمني", null, true, null, "Yemeni Rial" });

            migrationBuilder.InsertData(
                table: "PropertyTypes",
                columns: new[] { "TypeId", "CreatedAt", "CreatedBy", "DefaultAmenities", "DeletedAt", "DeletedBy", "Description", "Icon", "IsActive", "Name", "UpdatedAt", "UpdatedBy" },
                values: new object[,]
                {
                    { new Guid("11111111-1111-1111-1111-111111111111"), new DateTime(2025, 8, 28, 5, 4, 16, 593, DateTimeKind.Utc).AddTicks(7802), null, "[]", null, null, "فندق تقليدي بغرف وخدمات فندقية", "", true, "فندق", new DateTime(2025, 8, 28, 5, 4, 16, 593, DateTimeKind.Utc).AddTicks(7803), null },
                    { new Guid("22222222-2222-2222-2222-222222222222"), new DateTime(2025, 8, 28, 5, 4, 16, 593, DateTimeKind.Utc).AddTicks(7826), null, "[]", null, null, "شاليه للعائلات والمجموعات", "", true, "شاليه", new DateTime(2025, 8, 28, 5, 4, 16, 593, DateTimeKind.Utc).AddTicks(7826), null },
                    { new Guid("33333333-3333-3333-3333-333333333333"), new DateTime(2025, 8, 28, 5, 4, 16, 593, DateTimeKind.Utc).AddTicks(7830), null, "[]", null, null, "استراحة للإقامة المؤقتة", "", true, "استراحة", new DateTime(2025, 8, 28, 5, 4, 16, 593, DateTimeKind.Utc).AddTicks(7830), null },
                    { new Guid("44444444-4444-4444-4444-444444444444"), new DateTime(2025, 8, 28, 5, 4, 16, 593, DateTimeKind.Utc).AddTicks(7833), null, "[]", null, null, "فيلا خاصة للإقامة الفاخرة", "", true, "فيلا", new DateTime(2025, 8, 28, 5, 4, 16, 593, DateTimeKind.Utc).AddTicks(7833), null },
                    { new Guid("55555555-5555-5555-5555-555555555555"), new DateTime(2025, 8, 28, 5, 4, 16, 593, DateTimeKind.Utc).AddTicks(7835), null, "[]", null, null, "شقة مفروشة للإقامة قصيرة أو طويلة المدى", "", true, "شقة", new DateTime(2025, 8, 28, 5, 4, 16, 593, DateTimeKind.Utc).AddTicks(7835), null }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "RoleId", "CreatedAt", "CreatedBy", "DeletedAt", "DeletedBy", "IsActive", "Name", "UpdatedAt", "UpdatedBy" },
                values: new object[,]
                {
                    { new Guid("11111111-1111-1111-1111-111111111111"), new DateTime(2025, 8, 28, 5, 4, 16, 590, DateTimeKind.Utc).AddTicks(1038), null, null, null, true, "Admin", new DateTime(2025, 8, 28, 5, 4, 16, 590, DateTimeKind.Utc).AddTicks(1039), null },
                    { new Guid("22222222-2222-2222-2222-222222222222"), new DateTime(2025, 8, 28, 5, 4, 16, 590, DateTimeKind.Utc).AddTicks(1060), null, null, null, true, "Owner", new DateTime(2025, 8, 28, 5, 4, 16, 590, DateTimeKind.Utc).AddTicks(1060), null },
                    { new Guid("33333333-3333-3333-3333-333333333333"), new DateTime(2025, 8, 28, 5, 4, 16, 590, DateTimeKind.Utc).AddTicks(1063), null, null, null, true, "Manager", new DateTime(2025, 8, 28, 5, 4, 16, 590, DateTimeKind.Utc).AddTicks(1063), null },
                    { new Guid("44444444-4444-4444-4444-444444444444"), new DateTime(2025, 8, 28, 5, 4, 16, 590, DateTimeKind.Utc).AddTicks(1066), null, null, null, true, "Customer", new DateTime(2025, 8, 28, 5, 4, 16, 590, DateTimeKind.Utc).AddTicks(1067), null }
                });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "UserId", "CreatedAt", "CreatedBy", "DeletedAt", "DeletedBy", "Email", "EmailConfirmationToken", "EmailConfirmationTokenExpires", "EmailConfirmed", "EmailVerifiedAt", "FavoritesJson", "IsActive", "IsEmailVerified", "LastLoginDate", "LoyaltyTier", "Name", "Password", "PasswordResetToken", "PasswordResetTokenExpires", "Phone", "ProfileImage", "ProfileImageUrl", "SettingsJson", "TotalSpent", "UpdatedAt", "UpdatedBy" },
                values: new object[,]
                {
                    { new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), new DateTime(2025, 8, 28, 5, 4, 16, 827, DateTimeKind.Utc).AddTicks(1170), null, null, null, "admin@example.com", null, null, true, null, "[]", true, false, new DateTime(2025, 8, 28, 5, 4, 16, 827, DateTimeKind.Utc).AddTicks(1172), "Gold", "Admin User", "Admin@123", null, null, "1234567890", "", "", "{}", 0m, new DateTime(2025, 8, 28, 5, 4, 16, 827, DateTimeKind.Utc).AddTicks(1153), null },
                    { new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"), new DateTime(2025, 8, 28, 5, 4, 16, 827, DateTimeKind.Utc).AddTicks(1208), null, null, null, "owner@example.com", null, null, true, null, "[]", true, false, new DateTime(2025, 8, 28, 5, 4, 16, 827, DateTimeKind.Utc).AddTicks(1209), "Silver", "Property Owner User", "Owner@123", null, null, "0987654321", "", "", "{}", 0m, new DateTime(2025, 8, 28, 5, 4, 16, 827, DateTimeKind.Utc).AddTicks(1203), null }
                });

            migrationBuilder.InsertData(
                table: "UserRoles",
                columns: new[] { "RoleId", "UserId", "AssignedAt", "CreatedAt", "CreatedBy", "DeletedAt", "DeletedBy", "UserRoleId", "IsActive", "UpdatedAt", "UpdatedBy" },
                values: new object[,]
                {
                    { new Guid("11111111-1111-1111-1111-111111111111"), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), new DateTime(2025, 8, 28, 5, 4, 16, 827, DateTimeKind.Utc).AddTicks(1430), new DateTime(2025, 8, 28, 5, 4, 16, 827, DateTimeKind.Utc).AddTicks(1430), null, null, null, new Guid("cccccccc-cccc-cccc-cccc-cccccccccccc"), true, new DateTime(2025, 8, 28, 5, 4, 16, 827, DateTimeKind.Utc).AddTicks(1430), null },
                    { new Guid("22222222-2222-2222-2222-222222222222"), new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"), new DateTime(2025, 8, 28, 5, 4, 16, 827, DateTimeKind.Utc).AddTicks(1436), new DateTime(2025, 8, 28, 5, 4, 16, 827, DateTimeKind.Utc).AddTicks(1436), null, null, null, new Guid("dddddddd-dddd-dddd-dddd-dddddddddddd"), true, new DateTime(2025, 8, 28, 5, 4, 16, 827, DateTimeKind.Utc).AddTicks(1437), null }
                });

            migrationBuilder.CreateIndex(
                name: "IX_AdminActions_ActionType",
                table: "AdminActions",
                column: "ActionType");

            migrationBuilder.CreateIndex(
                name: "IX_AdminActions_AdminId",
                table: "AdminActions",
                column: "AdminId");

            migrationBuilder.CreateIndex(
                name: "IX_AdminActions_AdminId_Timestamp",
                table: "AdminActions",
                columns: new[] { "AdminId", "Timestamp" });

            migrationBuilder.CreateIndex(
                name: "IX_AdminActions_AdminId1",
                table: "AdminActions",
                column: "AdminId1");

            migrationBuilder.CreateIndex(
                name: "IX_AdminActions_TargetId_TargetType",
                table: "AdminActions",
                columns: new[] { "TargetId", "TargetType" });

            migrationBuilder.CreateIndex(
                name: "IX_AdminActions_TargetType",
                table: "AdminActions",
                column: "TargetType");

            migrationBuilder.CreateIndex(
                name: "IX_Amenities_Name",
                table: "Amenities",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_AuditLogs_PerformedBy",
                table: "AuditLogs",
                column: "PerformedBy");

            migrationBuilder.CreateIndex(
                name: "IX_Bookings_Booking_TotalPrice_Currency",
                table: "Bookings",
                column: "Booking_TotalPrice_Currency");

            migrationBuilder.CreateIndex(
                name: "IX_Bookings_CheckInOut",
                table: "Bookings",
                columns: new[] { "CheckIn", "CheckOut" });

            migrationBuilder.CreateIndex(
                name: "IX_Bookings_IsDeleted",
                table: "Bookings",
                column: "IsDeleted");

            migrationBuilder.CreateIndex(
                name: "IX_Bookings_Status",
                table: "Bookings",
                column: "Status");

            migrationBuilder.CreateIndex(
                name: "IX_Bookings_UnitId",
                table: "Bookings",
                column: "UnitId");

            migrationBuilder.CreateIndex(
                name: "IX_Bookings_UnitId_CheckIn_CheckOut",
                table: "Bookings",
                columns: new[] { "UnitId", "CheckIn", "CheckOut" });

            migrationBuilder.CreateIndex(
                name: "IX_Bookings_UserId",
                table: "Bookings",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Bookings_UserId_BookedAt",
                table: "Bookings",
                columns: new[] { "UserId", "BookedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_BookingServices_BookingId",
                table: "BookingServices",
                column: "BookingId");

            migrationBuilder.CreateIndex(
                name: "IX_BookingServices_IsDeleted",
                table: "BookingServices",
                column: "IsDeleted");

            migrationBuilder.CreateIndex(
                name: "IX_BookingServices_ServiceId",
                table: "BookingServices",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_ChatAttachments_ChatMessageId",
                table: "ChatAttachments",
                column: "ChatMessageId");

            migrationBuilder.CreateIndex(
                name: "IX_ChatAttachments_ConversationId",
                table: "ChatAttachments",
                column: "ConversationId");

            migrationBuilder.CreateIndex(
                name: "IX_ChatConversationParticipant_UserId",
                table: "ChatConversationParticipant",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_ChatConversations_PropertyId",
                table: "ChatConversations",
                column: "PropertyId");

            migrationBuilder.CreateIndex(
                name: "IX_ChatMessages_ConversationId",
                table: "ChatMessages",
                column: "ConversationId");

            migrationBuilder.CreateIndex(
                name: "IX_ChatMessages_ConversationId1",
                table: "ChatMessages",
                column: "ConversationId1");

            migrationBuilder.CreateIndex(
                name: "IX_ChatMessages_ReplyToMessageId",
                table: "ChatMessages",
                column: "ReplyToMessageId");

            migrationBuilder.CreateIndex(
                name: "IX_ChatMessages_SenderId",
                table: "ChatMessages",
                column: "SenderId");

            migrationBuilder.CreateIndex(
                name: "IX_ChatSettings_UserId",
                table: "ChatSettings",
                column: "UserId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Cities_Name_Country",
                table: "Cities",
                columns: new[] { "Name", "Country" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Currencies_IsDefault",
                table: "Currencies",
                column: "IsDefault");

            migrationBuilder.CreateIndex(
                name: "IX_FieldGroupFields_FieldId",
                table: "FieldGroupFields",
                column: "FieldId");

            migrationBuilder.CreateIndex(
                name: "IX_FieldGroupFields_GroupId",
                table: "FieldGroupFields",
                column: "GroupId");

            migrationBuilder.CreateIndex(
                name: "IX_FieldGroups_PropertyTypeId_SortOrder",
                table: "FieldGroups",
                columns: new[] { "UnitTypeId", "SortOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_IndexMetadata_LastUpdateTime",
                table: "IndexMetadata",
                column: "LastUpdateTime");

            migrationBuilder.CreateIndex(
                name: "IX_IndexMetadata_Status",
                table: "IndexMetadata",
                column: "Status",
                filter: "[Status] = 'Active'");

            migrationBuilder.CreateIndex(
                name: "IX_IndexMetadata_Status_LastUpdate",
                table: "IndexMetadata",
                columns: new[] { "Status", "LastUpdateTime" },
                filter: "[Status] = 'Active'");

            migrationBuilder.CreateIndex(
                name: "IX_MessageReactions_MessageId",
                table: "MessageReactions",
                column: "MessageId");

            migrationBuilder.CreateIndex(
                name: "IX_Notifications_RecipientId",
                table: "Notifications",
                column: "RecipientId");

            migrationBuilder.CreateIndex(
                name: "IX_Notifications_SenderId",
                table: "Notifications",
                column: "SenderId");

            migrationBuilder.CreateIndex(
                name: "IX_Payments_BookingId",
                table: "Payments",
                column: "BookingId");

            migrationBuilder.CreateIndex(
                name: "IX_Payments_IsDeleted",
                table: "Payments",
                column: "IsDeleted");

            migrationBuilder.CreateIndex(
                name: "IX_Payments_MethodId",
                table: "Payments",
                column: "MethodId");

            migrationBuilder.CreateIndex(
                name: "IX_Payments_Payment_Amount_Currency",
                table: "Payments",
                column: "Payment_Amount_Currency");

            migrationBuilder.CreateIndex(
                name: "IX_Payments_Status",
                table: "Payments",
                column: "Status");

            migrationBuilder.CreateIndex(
                name: "IX_Payments_TransactionId",
                table: "Payments",
                column: "TransactionId",
                unique: true,
                filter: "[TransactionId] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_PricingRules_Currency",
                table: "PricingRules",
                column: "Currency");

            migrationBuilder.CreateIndex(
                name: "IX_PricingRules_UnitId_StartDate_EndDate",
                table: "PricingRules",
                columns: new[] { "UnitId", "StartDate", "EndDate" });

            migrationBuilder.CreateIndex(
                name: "IX_Properties_City",
                table: "Properties",
                column: "City");

            migrationBuilder.CreateIndex(
                name: "IX_Properties_Currency",
                table: "Properties",
                column: "Currency");

            migrationBuilder.CreateIndex(
                name: "IX_Properties_Name_City",
                table: "Properties",
                columns: new[] { "Name", "City" });

            migrationBuilder.CreateIndex(
                name: "IX_Properties_OwnerId",
                table: "Properties",
                column: "OwnerId");

            migrationBuilder.CreateIndex(
                name: "IX_Properties_TypeId",
                table: "Properties",
                column: "TypeId");

            migrationBuilder.CreateIndex(
                name: "IX_PropertyAmenities_IsDeleted",
                table: "PropertyAmenities",
                column: "IsDeleted");

            migrationBuilder.CreateIndex(
                name: "IX_PropertyAmenities_PropertyId",
                table: "PropertyAmenities",
                column: "PropertyId");

            migrationBuilder.CreateIndex(
                name: "IX_PropertyAmenities_PropertyId_PtaId",
                table: "PropertyAmenities",
                columns: new[] { "PropertyId", "PtaId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_PropertyAmenities_PtaId",
                table: "PropertyAmenities",
                column: "PtaId");

            migrationBuilder.CreateIndex(
                name: "IX_PropertyImages_PropertyId",
                table: "PropertyImages",
                column: "PropertyId");

            migrationBuilder.CreateIndex(
                name: "IX_PropertyImages_UnitId",
                table: "PropertyImages",
                column: "UnitId");

            migrationBuilder.CreateIndex(
                name: "IX_PropertyPolicies_IsDeleted",
                table: "PropertyPolicies",
                column: "IsDeleted");

            migrationBuilder.CreateIndex(
                name: "IX_PropertyPolicies_PolicyType",
                table: "PropertyPolicies",
                column: "Type");

            migrationBuilder.CreateIndex(
                name: "IX_PropertyPolicies_PropertyId",
                table: "PropertyPolicies",
                column: "PropertyId");

            migrationBuilder.CreateIndex(
                name: "IX_PropertyPolicies_PropertyId_PolicyType",
                table: "PropertyPolicies",
                columns: new[] { "PropertyId", "Type" });

            migrationBuilder.CreateIndex(
                name: "IX_PropertyServices_IsDeleted",
                table: "PropertyServices",
                column: "IsDeleted");

            migrationBuilder.CreateIndex(
                name: "IX_PropertyServices_Name",
                table: "PropertyServices",
                column: "Name");

            migrationBuilder.CreateIndex(
                name: "IX_PropertyServices_PropertyId",
                table: "PropertyServices",
                column: "PropertyId");

            migrationBuilder.CreateIndex(
                name: "IX_PropertyTypeAmenities_AmenityId",
                table: "PropertyTypeAmenities",
                column: "AmenityId");

            migrationBuilder.CreateIndex(
                name: "IX_PropertyTypeAmenities_IsDeleted",
                table: "PropertyTypeAmenities",
                column: "IsDeleted");

            migrationBuilder.CreateIndex(
                name: "IX_PropertyTypeAmenities_PropertyTypeId",
                table: "PropertyTypeAmenities",
                column: "PropertyTypeId");

            migrationBuilder.CreateIndex(
                name: "IX_PropertyTypeAmenities_PropertyTypeId_AmenityId",
                table: "PropertyTypeAmenities",
                columns: new[] { "PropertyTypeId", "AmenityId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_PropertyTypes_Name",
                table: "PropertyTypes",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Reports_ReportedPropertyId",
                table: "Reports",
                column: "ReportedPropertyId");

            migrationBuilder.CreateIndex(
                name: "IX_Reports_ReportedUserId",
                table: "Reports",
                column: "ReportedUserId");

            migrationBuilder.CreateIndex(
                name: "IX_Reports_ReporterUserId",
                table: "Reports",
                column: "ReporterUserId");

            migrationBuilder.CreateIndex(
                name: "IX_ReviewImages_ReviewId",
                table: "ReviewImages",
                column: "ReviewId");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_BookingId",
                table: "Reviews",
                column: "BookingId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_IsDeleted",
                table: "Reviews",
                column: "IsDeleted");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_PropertyId",
                table: "Reviews",
                column: "PropertyId");

            migrationBuilder.CreateIndex(
                name: "IX_Roles_Name",
                table: "Roles",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_SearchFilters_FieldId",
                table: "SearchFilters",
                column: "FieldId");

            migrationBuilder.CreateIndex(
                name: "IX_SearchFilters_UnitTypeId",
                table: "SearchFilters",
                column: "UnitTypeId");

            migrationBuilder.CreateIndex(
                name: "IX_SectionItems_PropertyId",
                table: "SectionItems",
                column: "PropertyId");

            migrationBuilder.CreateIndex(
                name: "IX_SectionItems_SectionId_PropertyId_UnitId",
                table: "SectionItems",
                columns: new[] { "SectionId", "PropertyId", "UnitId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_SectionItems_UnitId",
                table: "SectionItems",
                column: "UnitId");

            migrationBuilder.CreateIndex(
                name: "IX_Staff_IsDeleted",
                table: "Staff",
                column: "IsDeleted");

            migrationBuilder.CreateIndex(
                name: "IX_Staff_PropertyId",
                table: "Staff",
                column: "PropertyId");

            migrationBuilder.CreateIndex(
                name: "IX_Staff_UserId",
                table: "Staff",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Staff_UserId_PropertyId",
                table: "Staff",
                columns: new[] { "UserId", "PropertyId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_UnitAvailability_BookingId",
                table: "UnitAvailability",
                column: "BookingId");

            migrationBuilder.CreateIndex(
                name: "IX_UnitAvailability_UnitId_StartDate_EndDate",
                table: "UnitAvailability",
                columns: new[] { "UnitId", "StartDate", "EndDate" });

            migrationBuilder.CreateIndex(
                name: "IX_UnitFieldValues_FieldId",
                table: "UnitFieldValues",
                column: "UnitTypeFieldId");

            migrationBuilder.CreateIndex(
                name: "IX_UnitFieldValues_UnitId",
                table: "UnitFieldValues",
                column: "UnitId");

            migrationBuilder.CreateIndex(
                name: "IX_Units_IsAvailable",
                table: "Units",
                column: "IsAvailable");

            migrationBuilder.CreateIndex(
                name: "IX_Units_IsDeleted",
                table: "Units",
                column: "IsDeleted");

            migrationBuilder.CreateIndex(
                name: "IX_Units_PricingMethod",
                table: "Units",
                column: "PricingMethod");

            migrationBuilder.CreateIndex(
                name: "IX_Units_PropertyId",
                table: "Units",
                column: "PropertyId");

            migrationBuilder.CreateIndex(
                name: "IX_Units_PropertyId_Name",
                table: "Units",
                columns: new[] { "PropertyId", "Name" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Units_UnitTypeId",
                table: "Units",
                column: "UnitTypeId");

            migrationBuilder.CreateIndex(
                name: "IX_UnitTypeFields_PropertyTypeId_FieldName",
                table: "UnitTypeFields",
                columns: new[] { "UnitTypeId", "FieldName" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_UnitTypes_Name_PropertyTypeId",
                table: "UnitTypes",
                columns: new[] { "Name", "PropertyTypeId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_UnitTypes_PropertyTypeId",
                table: "UnitTypes",
                column: "PropertyTypeId");

            migrationBuilder.CreateIndex(
                name: "IX_UserRoles_IsDeleted",
                table: "UserRoles",
                column: "IsDeleted");

            migrationBuilder.CreateIndex(
                name: "IX_UserRoles_RoleId",
                table: "UserRoles",
                column: "RoleId");

            migrationBuilder.CreateIndex(
                name: "IX_UserRoles_UserId",
                table: "UserRoles",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Users_Email",
                table: "Users",
                column: "Email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Users_IsDeleted",
                table: "Users",
                column: "IsDeleted");

            migrationBuilder.CreateIndex(
                name: "IX_Users_Phone",
                table: "Users",
                column: "Phone");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AdminActions");

            migrationBuilder.DropTable(
                name: "AuditLogs");

            migrationBuilder.DropTable(
                name: "BookingServices");

            migrationBuilder.DropTable(
                name: "ChatAttachments");

            migrationBuilder.DropTable(
                name: "ChatConversationParticipant");

            migrationBuilder.DropTable(
                name: "ChatSettings");

            migrationBuilder.DropTable(
                name: "FieldGroupFields");

            migrationBuilder.DropTable(
                name: "IndexMetadata");

            migrationBuilder.DropTable(
                name: "MessageReactions");

            migrationBuilder.DropTable(
                name: "Notifications");

            migrationBuilder.DropTable(
                name: "Payments");

            migrationBuilder.DropTable(
                name: "PricingRules");

            migrationBuilder.DropTable(
                name: "PropertyAmenities");

            migrationBuilder.DropTable(
                name: "PropertyImages");

            migrationBuilder.DropTable(
                name: "PropertyPolicies");

            migrationBuilder.DropTable(
                name: "Reports");

            migrationBuilder.DropTable(
                name: "ReviewImages");

            migrationBuilder.DropTable(
                name: "SearchFilters");

            migrationBuilder.DropTable(
                name: "SearchLogs");

            migrationBuilder.DropTable(
                name: "SectionItems");

            migrationBuilder.DropTable(
                name: "Staff");

            migrationBuilder.DropTable(
                name: "UnitAvailability");

            migrationBuilder.DropTable(
                name: "UnitFieldValues");

            migrationBuilder.DropTable(
                name: "UserRoles");

            migrationBuilder.DropTable(
                name: "PropertyServices");

            migrationBuilder.DropTable(
                name: "FieldGroups");

            migrationBuilder.DropTable(
                name: "ChatMessages");

            migrationBuilder.DropTable(
                name: "PaymentMethods");

            migrationBuilder.DropTable(
                name: "PropertyTypeAmenities");

            migrationBuilder.DropTable(
                name: "Reviews");

            migrationBuilder.DropTable(
                name: "Sections");

            migrationBuilder.DropTable(
                name: "UnitTypeFields");

            migrationBuilder.DropTable(
                name: "Roles");

            migrationBuilder.DropTable(
                name: "ChatConversations");

            migrationBuilder.DropTable(
                name: "Amenities");

            migrationBuilder.DropTable(
                name: "Bookings");

            migrationBuilder.DropTable(
                name: "Units");

            migrationBuilder.DropTable(
                name: "Properties");

            migrationBuilder.DropTable(
                name: "UnitTypes");

            migrationBuilder.DropTable(
                name: "Cities");

            migrationBuilder.DropTable(
                name: "Currencies");

            migrationBuilder.DropTable(
                name: "Users");

            migrationBuilder.DropTable(
                name: "PropertyTypes");
        }
    }
}
