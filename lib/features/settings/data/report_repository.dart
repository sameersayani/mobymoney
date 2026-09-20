import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mobymoney/core/errors/network_exception.dart';
import 'package:mobymoney/core/networking/api_client.dart';
import 'package:mobymoney/core/networking/api_endpoints.dart';

class ReportRepository {
  ReportRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  /// Downloads the Excel (.xlsx) expense report from GET /download-report
  /// If [month] is provided, generates monthly report.
  /// If [month] is null, generates full yearly report.
  /// Saves the file locally and returns the resulting [File].
  Future<File> downloadExpenseReport({
    required int year,
    int? month,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'year': year,
      };
      if (month != null) {
        queryParams['month'] = month;
      }

      final response = await _apiClient.dio.get<List<int>>(
        ApiEndpoints.downloadReport,
        queryParameters: queryParams,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
      );

      final data = response.data;
      if (data == null || data.isEmpty) {
        throw const NetworkException(message: 'Server returned empty report data');
      }

      // Save to local device storage
      final directory = await getApplicationDocumentsDirectory();
      final fileName = month != null
          ? 'MobyMoney_Report_${year}_${month.toString().padLeft(2, '0')}.xlsx'
          : 'MobyMoney_Report_${year}_FullYear.xlsx';

      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(data, flush: true);

      return file;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Failed to download report: ${e.toString()}',
      );
    }
  }
}
