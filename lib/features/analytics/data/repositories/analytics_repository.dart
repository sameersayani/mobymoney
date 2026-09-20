import 'package:dio/dio.dart';
import '../../../../core/errors/network_exception.dart';
import '../../../../core/networking/api_client.dart';
import '../../../../core/networking/api_endpoints.dart';
import '../../domain/models/chart_data_model.dart';

class AnalyticsRepository {
  AnalyticsRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  /// GET /chart-data?month=...&year=...
  Future<ChartDataModel> getChartData({
    int? month,
    int? year,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      final response = await _apiClient.dio.get(
        ApiEndpoints.chartData,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ChartDataModel.fromJson(data);
      }

      return ChartDataModel.empty();
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Failed to load chart data: ${e.toString()}',
      );
    }
  }
}
