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
      final response = await apiClient.post(
        _adminPath,
        data: city.toJson(),
      );
      
      if (response.data['success'] == true) {
        // إرجاع معرف المدينة المنشأة
        if (response.data['data'] is Map) {
          return response.data['data']['name'] ?? '';
        }
        return response.data['data'] ?? '';
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to create city',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// ✏️ تحديث مدينة موجودة
  @override
  Future<bool> updateCity(String oldName, CityModel city) async {
    try {
      final response = await apiClient.put(
        '$_adminPath/$oldName',
        data: city.toJson(),
      );
      
      if (response.data['success'] == true) {
        return true;
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to update city',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// 🗑️ حذف مدينة
  @override
  Future<bool> deleteCity(String name) async {
    try {
      final response = await apiClient.delete('$_adminPath/$name');
      
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// 🔍 البحث في المدن
  @override
  Future<List<CityModel>> searchCities(String query) async {
    try {
      final response = await apiClient.get(
        '$_adminPath/search',
        queryParameters: {'q': query},
      );
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => CityModel.fromJson(json)).toList();
      }
      
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// 📊 الحصول على إحصائيات المدن
  @override
  Future<Map<String, dynamic>> getCitiesStatistics() async {
    try {
      final response = await apiClient.get('$_adminPath/statistics');
      
      if (response.data['success'] == true) {
        return response.data['data'] ?? {};
      }
      
      return {};
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
      
      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map) {
          return data['url'] ?? '';
        }
        return '';
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
      final response = await apiClient.delete(
        _imagesPath,
        queryParameters: {'url': imageUrl},
      );
      
      return response.data['success'] == true;
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