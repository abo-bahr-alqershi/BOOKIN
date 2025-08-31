import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/models/paginated_result.dart';
import '../models/city_model.dart';

/// 🌐 Remote Data Source للمدن
abstract class CitiesRemoteDataSource {
  /// الحصول على جميع المدن
  Future<List<CityModel>> getCities();
  
  /// حفظ قائمة المدن (إضافة أو تحديث)
  Future<bool> saveCities(List<CityModel> cities);
  
  /// إضافة مدينة جديدة
  Future<String> createCity(CityModel city);
  
  /// تحديث مدينة موجودة
  Future<bool> updateCity(String oldName, CityModel city);
  
  /// حذف مدينة
  Future<bool> deleteCity(String name);
  
  /// البحث في المدن
  Future<List<CityModel>> searchCities(String query);
  
  /// الحصول على إحصائيات المدن
  Future<Map<String, dynamic>> getCitiesStatistics();
  
  /// رفع صورة للمدينة
  Future<String> uploadCityImage(String imagePath);
  
  /// حذف صورة من المدينة
  Future<bool> deleteCityImage(String imageUrl);
  
  /// الحصول على المدن بصفحات
  Future<PaginatedResult<CityModel>> getCitiesPaginated({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? country,
    bool? isActive,
  });
}

class CitiesRemoteDataSourceImpl implements CitiesRemoteDataSource {
  final ApiClient apiClient;
  
  /// 🔗 المسار الأساسي لـ API المدن
  static const String _basePath = '/api/admin/system-settings/cities';
  // لا يوجد CitiesController على الـ backend؛ نُبقي فقط على مسارات system-settings
  static const String _adminPath = '/api/admin/cities';
  static const String _imagesPath = '/api/images';

  CitiesRemoteDataSourceImpl({required this.apiClient});

  /// 📋 الحصول على جميع المدن
  @override
  Future<List<CityModel>> getCities() async {
    try {
      final response = await apiClient.get(_basePath);
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => CityModel.fromJson(json)).toList();
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to fetch cities',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// 💾 حفظ قائمة المدن
  @override
  Future<bool> saveCities(List<CityModel> cities) async {
    try {
      final citiesJson = cities.map((city) => city.toJson()).toList();
      
      final response = await apiClient.put(
        _basePath,
        data: citiesJson,
      );
      
      if (response.data['success'] == true) {
        return response.data['data'] ?? false;
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to save cities',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// ➕ إضافة مدينة جديدة
  @override
  Future<String> createCity(CityModel city) async {
    try {
      // لا يوجد مسار لإنشاء مدينة منفردة؛ ندمجها ضمن القائمة ونحفظ عبر PUT
      final existing = await getCities();
      final updated = [...existing, city];
      final ok = await saveCities(updated);
      if (ok) {
        return city.name;
      }
      throw ApiException(message: 'Failed to create city');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// ✏️ تحديث مدينة موجودة
  @override
  Future<bool> updateCity(String oldName, CityModel city) async {
    try {
      // تحديث عبر جلب القائمة وتعديل العنصر ثم PUT للقائمة كاملة
      final existing = await getCities();
      final idx = existing.indexWhere((c) => c.name == oldName);
      if (idx == -1) throw ApiException(message: 'City not found');
      final List<CityModel> updated = List.of(existing);
      updated[idx] = city;
      return await saveCities(updated);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// 🗑️ حذف مدينة
  @override
  Future<bool> deleteCity(String name) async {
    try {
      // حذف عبر إعادة حفظ القائمة بدون هذه المدينة
      final existing = await getCities();
      final updated = existing.where((c) => c.name != name).toList();
      return await saveCities(updated);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// 🔍 البحث في المدن
  @override
  Future<List<CityModel>> searchCities(String query) async {
    try {
      final all = await getCities();
      final q = query.toLowerCase();
      return all.where((c) => c.name.toLowerCase().contains(q) || c.country.toLowerCase().contains(q)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// 📊 الحصول على إحصائيات المدن
  @override
  Future<Map<String, dynamic>> getCitiesStatistics() async {
    try {
      final all = await getCities();
      final total = all.length;
      final active = all.where((c) => c.isActive ?? true).length;
      final byCountry = <String, int>{};
      for (final c in all) {
        byCountry[c.country] = (byCountry[c.country] ?? 0) + 1;
      }
      return {
        'total': total,
        'active': active,
        'byCountry': byCountry,
      };
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// 📤 رفع صورة للمدينة
  @override
  Future<String> uploadCityImage(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imagePath),
        'category': 'city',
      });

      final response = await apiClient.post(
        '$_imagesPath/upload',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      
      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map['success'] == true) {
          final data = map['image'] ?? map['data'];
          if (data is Map && data['url'] != null) {
            return data['url'] as String;
          }
        }
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to upload image',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// 🗑️ حذف صورة من المدينة
  @override
  Future<bool> deleteCityImage(String imageUrl) async {
    try {
      // لا يوجد مسار حذف حسب URL؛ يحتاج ID عادةً. سنعيد false إن لم يكن مدعوماً
      // بديل: يمكن جلب الصور ثم حذف المطابق ل URL إذا توفر id
      return false;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// 📑 الحصول على المدن بصفحات
  @override
  Future<PaginatedResult<CityModel>> getCitiesPaginated({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? country,
    bool? isActive,
  }) async {
    try {
      final response = await apiClient.get(
        '$_adminPath/paginated',
        queryParameters: {
          if (pageNumber != null) 'pageNumber': pageNumber,
          if (pageSize != null) 'pageSize': pageSize,
          if (search != null && search.isNotEmpty) 'search': search,
          if (country != null && country.isNotEmpty) 'country': country,
          if (isActive != null) 'isActive': isActive,
        },
      );
      
      // إذا كانت الاستجابة تحتوي على بيانات مُرَقَّمة
      if (response.data['success'] == true && response.data['data'] != null) {
        return PaginatedResult<CityModel>.fromJson(
          response.data,
          (json) => CityModel.fromJson(json),
        );
      }
      
      // إذا لم تكن هناك بيانات مُرَقَّمة، نعيد قائمة فارغة
      return PaginatedResult<CityModel>(
        items: [],
        totalCount: 0,
        pageNumber: pageNumber ?? 1,
        pageSize: pageSize ?? 10,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}