import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mobymoney/core/errors/network_exception.dart';
import 'package:mobymoney/core/networking/api_client.dart';
import 'package:mobymoney/core/networking/api_endpoints.dart';
import 'package:mobymoney/features/dashboard/domain/models/dashboard_summary_model.dart';
import 'package:mobymoney/features/settings/data/expense_export_service.dart';

class ReportRepository {
  ReportRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  /// Saves bytes to the app's cache directory.
  /// This is guaranteed to work on all Android versions (no scoped-storage issues).
  /// The UI layer (share_plus) then handles saving to public Downloads.
  Future<File> _saveBytesSafely(List<int> bytes, String fileName) async {
    // Try multiple writable locations in priority order
    final candidates = <Future<Directory> Function()>[
      () => getTemporaryDirectory(),
      () => getApplicationCacheDirectory(),
      () => getApplicationDocumentsDirectory(),
    ];

    for (final getDir in candidates) {
      try {
        final dir = await getDir();
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes, flush: true);
        debugPrint('[ReportRepo] Saved to: ${file.path}');
        return file;
      } catch (e) {
        debugPrint('[ReportRepo] Candidate dir failed: $e');
      }
    }

    throw const NetworkException(
      message: 'Could not access local storage to save the report.',
    );
  }

  /// Saves string/CSV to app cache dir.
  Future<File> _saveStringSafely(String content, String fileName) async {
    final candidates = <Future<Directory> Function()>[
      () => getTemporaryDirectory(),
      () => getApplicationCacheDirectory(),
      () => getApplicationDocumentsDirectory(),
    ];

    for (final getDir in candidates) {
      try {
        final dir = await getDir();
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        final file = File('${dir.path}/$fileName');
        await file.writeAsString(content, flush: true);
        debugPrint('[ReportRepo] Saved CSV to: ${file.path}');
        return file;
      } catch (e) {
        debugPrint('[ReportRepo] Candidate dir failed: $e');
      }
    }

    throw const NetworkException(
      message: 'Could not access local storage to save the report.',
    );
  }

  /// Downloads the Excel (.xlsx) or CSV expense report.
  Future<File> downloadExpenseReport({
    required int year,
    int? month,
    List<RecentExpenseItemModel>? fallbackExpenses,
  }) async {
    final fileName = month != null
        ? 'MobyMoney_Report_${year}_${month.toString().padLeft(2, '0')}.xlsx'
        : 'MobyMoney_Report_${year}_FullYear.xlsx';

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

      return await _saveBytesSafely(data, fileName);
    } on DioException catch (e) {
      debugPrint('Network report download failed, falling back to local generator: $e');
      if (fallbackExpenses != null && fallbackExpenses.isNotEmpty) {
        return _generateLocalReportFile(
          expenses: fallbackExpenses,
          year: year,
          month: month,
        );
      }
      throw NetworkException.fromDioException(e);
    } catch (e) {
      if (fallbackExpenses != null && fallbackExpenses.isNotEmpty) {
        return _generateLocalReportFile(
          expenses: fallbackExpenses,
          year: year,
          month: month,
        );
      }
      throw NetworkException(
        message: 'Failed to download report: ${e.toString()}',
      );
    }
  }

  Future<File> _generateLocalReportFile({
    required List<RecentExpenseItemModel> expenses,
    required int year,
    int? month,
  }) async {
    final csvContent = ExpenseExportService.generateReport(
      expenses: expenses,
      year: year,
      month: month,
    );

    final csvName = month != null
        ? 'MobyMoney_Report_${year}_${month.toString().padLeft(2, '0')}.csv'
        : 'MobyMoney_Report_${year}_FullYear.csv';

    return await _saveStringSafely(csvContent, csvName);
  }
}
