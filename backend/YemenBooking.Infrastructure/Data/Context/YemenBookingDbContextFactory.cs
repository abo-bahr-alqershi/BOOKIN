using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.AspNetCore.Http;
using YemenBooking.Infrastructure.Data.Context;
using Microsoft.EntityFrameworkCore.Diagnostics;

namespace YemenBooking.Infrastructure.Data.Context;

/// <summary>
/// Factory for design-time DbContext creation.
/// مولد سياق قاعدة البيانات في وقت التصميم
/// </summary>
public class YemenBookingDbContextFactory : IDesignTimeDbContextFactory<YemenBookingDbContext>
{
    public YemenBookingDbContext CreateDbContext(string[] args)
    {
        var optionsBuilder = new DbContextOptionsBuilder<YemenBookingDbContext>();
        // // تهيئة الاتصال بقاعدة بيانات SQLite
        // optionsBuilder.UseSqlite("Data Source=YemenBooking.db");
        // تهيئة الاتصال بقاعدة بيانات SQL Server باستخدام المتغيرات البيئية
        var connectionString = Environment.GetEnvironmentVariable("DEFAULT_CONNECTION_STRING")
                               ?? Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection");

        if (string.IsNullOrWhiteSpace(connectionString))
        {
            throw new InvalidOperationException("Default connection string is not configured. Set DEFAULT_CONNECTION_STRING or ConnectionStrings__DefaultConnection environment variable.");
        }

        optionsBuilder.UseSqlServer(connectionString);
        // For design-time, httpContextAccessor not used, passing new HttpContextAccessor instance
        return new YemenBookingDbContext(
            optionsBuilder.Options,
            new HttpContextAccessor());
    }
} 