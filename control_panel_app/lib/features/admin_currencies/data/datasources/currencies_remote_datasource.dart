import 'package:bookn_cp_app/core/network/api_exceptions.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/currency_model.dart';

abstract class CurrenciesRemoteDataSource {
  Future<List<CurrencyModel>> getCurrencies();
  Future<bool> saveCurrencies(List<CurrencyModel> currencies);
}

class CurrenciesRemoteDataSourceImpl implements CurrenciesRemoteDataSource {
  final ApiClient apiClient;

  CurrenciesRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<CurrencyModel>> getCurrencies() async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.commonBaseUrl}/system-settings/currencies',
      );

      if (response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((json) => CurrencyModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<bool> saveCurrencies(List<CurrencyModel> currencies) async {
    try {
      final response = await apiClient.put(
        '${ApiConstants.adminBaseUrl}/system-settings/currencies',
        data: currencies.map((c) => c.toJson()).toList(),
      );

      return response.data['data'] ?? false;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final message = e.response?.data['message'] ?? 'خطأ في الخادم';
      throw ApiException.fromDioError(e);
    }
    return ApiException(message: 'خطأ في الاتصال');
  }
}