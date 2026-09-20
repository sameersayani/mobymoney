import 'package:dio/dio.dart';
import '../../../../core/errors/network_exception.dart';
import '../../../../core/networking/api_client.dart';
import '../../../../core/networking/api_endpoints.dart';
import '../../domain/models/expense_type_model.dart';

class ExpenseTypeRepository {
  ExpenseTypeRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  /// Fetches all dynamic expense types from GET /expensetype
  Future<List<ExpenseTypeModel>> getExpenseTypes() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.expenseTypes);
      final data = response.data;

      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ExpenseTypeModel.fromJson)
            .toList();
      } else if (data is List<dynamic>) {
        return data
            .map((item) =>
                ExpenseTypeModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Failed to load expense types: ${e.toString()}',
      );
    }
  }
}
