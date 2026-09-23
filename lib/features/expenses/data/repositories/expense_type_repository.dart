import 'package:dio/dio.dart';
import '../../../../core/errors/network_exception.dart';
import '../../../../core/networking/api_client.dart';
import '../../../../core/networking/api_endpoints.dart';
import '../../domain/models/expense_type_model.dart';

class ExpenseTypeRepository {
  ExpenseTypeRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  /// GET /expensetype — Fetches all dynamic expense types
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

  /// GET /expensetype/{id} — Fetches a single expense type by ID
  Future<ExpenseTypeModel> getExpenseTypeById(int id) async {
    try {
      final response =
          await _apiClient.dio.get(ApiEndpoints.expenseTypeById(id));
      final data = response.data;

      if (data is Map<String, dynamic>) {
        return ExpenseTypeModel.fromJson(data);
      } else {
        throw const NetworkException(
          message: 'Invalid response format from server.',
        );
      }
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Failed to fetch expense type #$id: ${e.toString()}',
      );
    }
  }

  /// POST /expensetype — Creates a new expense type
  Future<ExpenseTypeModel> createExpenseType(String name) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.expenseTypes,
        data: {'name': name.trim()},
      );
      final data = response.data;

      if (data is Map<String, dynamic>) {
        return ExpenseTypeModel.fromJson(data);
      } else {
        // Some backends return status string or id directly
        return ExpenseTypeModel(id: DateTime.now().millisecondsSinceEpoch, name: name.trim());
      }
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Failed to create expense type: ${e.toString()}',
      );
    }
  }

  /// PUT /expensetype/{id} — Updates an existing expense type
  Future<ExpenseTypeModel> updateExpenseType(int id, String name) async {
    try {
      final response = await _apiClient.dio.put(
        ApiEndpoints.expenseTypeById(id),
        data: {'name': name.trim()},
      );
      final data = response.data;

      if (data is Map<String, dynamic>) {
        return ExpenseTypeModel.fromJson(data);
      } else {
        return ExpenseTypeModel(id: id, name: name.trim());
      }
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Failed to update expense type #$id: ${e.toString()}',
      );
    }
  }

  /// DELETE /expensetype/{id} — Deletes an expense type by ID
  Future<void> deleteExpenseType(int id) async {
    try {
      await _apiClient.dio.delete(ApiEndpoints.expenseTypeById(id));
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Failed to delete expense type #$id: ${e.toString()}',
      );
    }
  }
}
