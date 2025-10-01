# تقرير إصلاح مشكلة ProfileImage و Provider
## ProfileImage Fix & Provider Issue Report

**التاريخ / Date**: 2025-10-01

---

## 🎯 المشاكل التي تم إصلاحها / Fixed Issues

### 1. ❌ مشكلة ProfileImage Required
**الوصف**: 
- عند إنشاء مستخدم جديد بدون صورة، كان يظهر خطأ:
  ```
  Cannot insert the value NULL into column 'ProfileImage', table 'db_abd8fd_bookn2.dbo.Users'; 
  column does not allow nulls. INSERT fails.
  ```

**السبب**:
- قاعدة البيانات لا تقبل `NULL` في عمود `ProfileImage`
- الكود كان يرسل `null` عندما لا توجد صورة

### 2. ❌ مشكلة Provider في BottomSheet
**الوصف**:
- عند محاولة تغيير دور المستخدم من صفحة التفاصيل، كان يظهر خطأ:
  ```
  Error: Could not find the correct Provider<UserDetailsBloc> above this BottomSheet Widget
  ```

**السبب**:
- الـ `BottomSheet` يُنشأ في سياق (`BuildContext`) جديد لا يحتوي على `UserDetailsBloc`
- استخدام `context.read<UserDetailsBloc>()` داخل الـ `builder` يبحث في السياق الجديد

---

## ✅ الحلول المطبقة / Applied Solutions

### 1. إصلاح ProfileImage في Backend

#### أ) CreateUserCommand.cs
**الملف**: `/backend/YemenBooking.Application/Commands/CP/Users/CreateUserCommand.cs`

```csharp
// قبل
public string ProfileImage { get; set; }

// بعد
public string? ProfileImage { get; set; }
```

#### ب) CreateUserCommandHandler.cs
**الملف**: `/backend/YemenBooking.Application/Handlers/Commands/Users/CreateUserCommandHandler.cs`

```csharp
// قبل
ProfileImage = request.ProfileImage?.Trim(),

// بعد
ProfileImage = string.IsNullOrWhiteSpace(request.ProfileImage) ? string.Empty : request.ProfileImage.Trim(),
```

#### ج) User Entity
**الملف**: `/backend/YemenBooking.Core/Entities/User.cs`

```csharp
// قبل
public string ProfileImage { get; set; }

// بعد
public string ProfileImage { get; set; } = string.Empty;
```

### 2. إصلاح إرسال البيانات من Flutter

#### users_remote_datasource.dart
**الملف**: `/control_panel_app/lib/features/admin_users/data/datasources/users_remote_datasource.dart`

```dart
// قبل
data: {
  'name': name,
  'email': email,
  'password': password,
  'phone': phone,
  if (profileImage != null) 'profileImage': profileImage,
},

// بعد
data: {
  'name': name,
  'email': email,
  'password': password,
  'phone': phone,
  'profileImage': profileImage ?? '', // إرسال string فارغ بدلاً من null
},
```

### 3. تحسين معالجة أخطاء التحقق

#### api_client.dart
**الملف**: `/control_panel_app/lib/core/network/api_client.dart`

```dart
// قبل
if (errorData['errors'] is Map) {
  final errors = errorData['errors'] as Map;
  final errorDetails = errors.entries
      .map((e) => '${e.key}: ${e.value}')
      .join(', ');
  errorMessage = 'أخطاء في: $errorDetails';
}

// بعد
if (errorData['errors'] is Map) {
  // أخطاء التحقق من النموذج
  final errors = errorData['errors'] as Map;
  final List<String> errorMessages = [];
  
  errors.forEach((key, value) {
    if (value is List && value.isNotEmpty) {
      // استخراج الرسائل من قائمة الأخطاء
      errorMessages.addAll(value.map((e) => e.toString()));
    } else {
      errorMessages.add(value.toString());
    }
  });
  
  errorMessage = errorMessages.join('\n');
}
```

**الفائدة**: 
- عرض رسائل الأخطاء بشكل واضح ومباشر
- بدلاً من: `أخطاء في: ProfileImage: [The ProfileImage field is required.]`
- الآن: `The ProfileImage field is required.`

### 4. إصلاح مشكلة Provider في BottomSheet

#### user_details_page.dart
**الملف**: `/control_panel_app/lib/features/admin_users/presentation/pages/user_details_page.dart`

```dart
// قبل
void _showRoleSelector(UserDetailsLoaded state) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => UserRoleSelector(
      currentRole: state.userDetails.role,
      onRoleSelected: (roleId) {
        context.read<UserDetailsBloc>().add(  // ❌ خطأ: context جديد
          AssignUserRoleEvent(
            userId: widget.userId,
            roleId: roleId,
          ),
        );
      },
    ),
  );
}

// بعد
void _showRoleSelector(UserDetailsLoaded state) {
  // حفظ الـ bloc قبل فتح الـ BottomSheet
  final bloc = context.read<UserDetailsBloc>();  // ✅ حفظ من السياق الأصلي
  
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => UserRoleSelector(
      currentRole: state.userDetails.role,
      onRoleSelected: (roleId) {
        // استخدام الـ bloc المحفوظ
        bloc.add(  // ✅ استخدام المرجع المحفوظ
          AssignUserRoleEvent(
            userId: widget.userId,
            roleId: roleId,
          ),
        );
      },
    ),
  );
}
```

**الشرح**:
- عند فتح `showModalBottomSheet`، الـ `builder` يعطي `BuildContext` جديد
- هذا السياق الجديد ليس تحت شجرة الـ `Provider<UserDetailsBloc>`
- الحل: حفظ مرجع للـ `bloc` قبل فتح الـ BottomSheet واستخدامه مباشرة

---

## 📦 ملف Migration لقاعدة البيانات

**الملف**: `/backend/docs/migrations/make_profileimage_nullable.sql`

```sql
-- Migration: Make ProfileImage column nullable
-- Date: 2025-10-01

USE [db_abd8fd_bookn2];
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Users')
BEGIN
    IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Users' AND COLUMN_NAME = 'ProfileImage')
    BEGIN
        -- تحديث السجلات الموجودة
        UPDATE [dbo].[Users]
        SET [ProfileImage] = ''
        WHERE [ProfileImage] IS NULL;
        
        -- تعديل العمود ليصبح nullable
        ALTER TABLE [dbo].[Users]
        ALTER COLUMN [ProfileImage] NVARCHAR(500) NULL;
        
        PRINT 'تم تعديل عمود ProfileImage بنجاح';
    END
END
GO
```

**ملاحظة**: يمكن تشغيل هذا السكريبت لجعل العمود يقبل `NULL` في قاعدة البيانات، لكن الكود الحالي يعمل بشكل صحيح بإرسال string فارغ.

---

## 🧪 اختبار التعديلات / Testing

### Backend
```bash
cd backend
dotnet build
dotnet run --project YemenBooking.Api
```

### Flutter
```bash
cd control_panel_app
flutter analyze
flutter run
```

### سيناريوهات الاختبار:
1. ✅ إنشاء مستخدم بدون صورة
2. ✅ إنشاء مستخدم بصورة
3. ✅ تغيير دور المستخدم من صفحة التفاصيل
4. ✅ عرض رسائل أخطاء التحقق بشكل واضح

---

## 📝 الملفات المعدلة / Modified Files

### Backend
1. `/backend/YemenBooking.Application/Commands/CP/Users/CreateUserCommand.cs`
2. `/backend/YemenBooking.Application/Handlers/Commands/Users/CreateUserCommandHandler.cs`
3. `/backend/YemenBooking.Core/Entities/User.cs`

### Flutter (control_panel_app)
1. `/control_panel_app/lib/core/network/api_client.dart`
2. `/control_panel_app/lib/features/admin_users/data/datasources/users_remote_datasource.dart`
3. `/control_panel_app/lib/features/admin_users/presentation/pages/user_details_page.dart`

### Documentation
1. `/backend/docs/migrations/make_profileimage_nullable.sql` (جديد)
2. `/PROFILEIMAGE_FIX_REPORT.md` (هذا الملف)

---

## 🎓 الدروس المستفادة / Lessons Learned

### 1. Provider Scope في Flutter
- الـ `BuildContext` في `showModalBottomSheet` هو سياق جديد
- يجب حفظ مرجع للـ Bloc/Provider قبل فتح الـ Dialog/BottomSheet
- البديل: استخدام `BlocProvider.value` لتمرير الـ bloc للسياق الجديد

### 2. معالجة NULL في قاعدة البيانات
- تأكد من توافق الـ Entity مع قاعدة البيانات
- استخدم قيم افتراضية بدلاً من `null` عند الإمكان
- وثق قيود قاعدة البيانات في الكود

### 3. معالجة الأخطاء
- افصل بين رسائل الأخطاء للمطورين والمستخدمين
- استخرج الرسائل من البنية المعقدة للأخطاء
- اعرض رسائل واضحة ومباشرة للمستخدم

---

## ✅ الحالة النهائية / Final Status

- [x] إصلاح ProfileImage في Backend
- [x] إصلاح إرسال البيانات من Flutter
- [x] تحسين معالجة الأخطاء
- [x] إصلاح مشكلة Provider في BottomSheet
- [x] إنشاء سكريبت SQL للتعديل المستقبلي
- [x] توثيق جميع التغييرات

**النتيجة**: جميع المشاكل تم حلها بنجاح! ✨
