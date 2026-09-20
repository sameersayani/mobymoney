import 'package:dio/dio.dart';
import '../../../../core/errors/network_exception.dart';
import '../../../../core/networking/api_client.dart';
import '../../../../core/networking/api_endpoints.dart';
import '../../domain/models/daily_expense_model.dart';

class DailyExpenseRepository {
  DailyExpenseRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  /// GET /dailyexpense?month=...&year=...
  Future<DailyExpenseResponseModel> getDailyExpenses({
    int? month,
    int? year,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      final response = await _apiClient.dio.get(
        ApiEndpoints.dailyExpense,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return DailyExpenseResponseModel.fromJson(data);
      }

      return DailyExpenseResponseModel.empty();
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Failed to load daily expenses: ${e.toString()}',
      );
    }
  }

  /// GET /dailyexpense/{id}
  Future<DailyExpenseItemModel> getExpenseById(dynamic id) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.dailyExpenseById(id),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return DailyExpenseItemModel.fromJson(data);
      }
      throw const NetworkException(message: 'Invalid expense response from server');
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Failed to load expense details: ${e.toString()}',
      );
    }
  }

  /// GET /search-expense/{name}
  Future<List<DailyExpenseItemModel>> searchExpenseByProduct(String name) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.searchExpense(Uri.encodeComponent(name)),
      );

      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(DailyExpenseItemModel.fromJson)
            .toList();
      }
      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map(DailyExpenseItemModel.fromJson)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Failed to search expenses: ${e.toString()}',
      );
    }
  }

  /// POST /dailyexpense/{expensetype_id}
  Future<dynamic> addExpense({
    required int expenseTypeId,
    required DateTime date,
    required String name,
    required int quantityPurchased,
    required double unitPrice,
    required double amount,
    required bool reallyNeeded,
  }) async {
    try {
      final payload = {
        'date': date.toIso8601String(),
        'name': name,
        'quantity_purchased': quantityPurchased,
        'unit_price': unitPrice,
        'amount': amount,
        'really_needed': reallyNeeded,
      };

      final response = await _apiClient.dio.post(
        ApiEndpoints.addDailyExpense(expenseTypeId),
        data: payload,
      );

      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Failed to add expense: ${e.toString()}',
      );
    }
  }

  /// PUT /dailyexpense/{expense_id}
  Future<dynamic> updateExpense({
    required dynamic expenseId,
    required int expenseTypeId,
    required DateTime date,
    required String name,
    required int quantityPurchased,
    required double unitPrice,
    required double amount,
    required bool reallyNeeded,
  }) async {
    try {
      final payload = {
        'date': date.toIso8601String(),
        'name': name,
        'quantity_purchased': quantityPurchased,
        'unit_price': unitPrice,
        'amount': amount,
        'really_needed': reallyNeeded,
        'expense_type_id': expenseTypeId,
      };

      final response = await _apiClient.dio.put(
        ApiEndpoints.updateDailyExpense(expenseId),
        data: payload,
      );

      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Failed to update expense: ${e.toString()}',
      );
    }
  }

  /// DELETE /dailyexpense/{dailyexpense_id}
  Future<dynamic> deleteExpense(dynamic dailyExpenseId) async {
    try {
      final response = await _apiClient.dio.delete(
        ApiEndpoints.deleteDailyExpense(dailyExpenseId),
      );

      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Failed to delete expense: ${e.toString()}',
      );
    }
  }
}
