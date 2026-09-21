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

  /// Safely writes bytes to an accessible local directory without OS permission errors.
  Future<File> _saveBytesSafely(List<int> bytes, String fileName) async {
    final candidateDirs = <Future<Directory?> Function()>[
      () async {
        if (Platform.isAndroid) {
          try {
            return await getExternalStorageDirectory();
          } catch (_) {}
        }
        return null;
      },
      () async => await getApplicationDocumentsDirectory(),
      () async => await getTemporaryDirectory(),
    ];

    for (final dirGetter in candidateDirs) {
      try {
        final dir = await dirGetter();
        if (dir != null) {
          if (!await dir.exists()) {
            await dir.create(recursive: true);
          }
          final file = File('${dir.path}/$fileName');
          await file.writeAsBytes(bytes, flush: true);
          return file;
        }
      } catch (e) {
        debugPrint('Failed writing file to directory candidate: $e');
      }
    }

    throw const NetworkException(
      message: 'Could not access local storage to save the report.',
    );
  }

  /// Safely writes text/CSV content to an accessible local directory without permission errors.
  Future<File> _saveStringSafely(String content, String fileName) async {
    final candidateDirs = <Future<Directory?> Function()>[
      () async {
        if (Platform.isAndroid) {
          try {
            return await getExternalStorageDirectory();
          } catch (_) {}
        }
        return null;
      },
      () async => await getApplicationDocumentsDirectory(),
      () async => await getTemporaryDirectory(),
    ];

    for (final dirGetter in candidateDirs) {
      try {
        final dir = await dirGetter();
        if (dir != null) {
          if (!await dir.exists()) {
            await dir.create(recursive: true);
          }
          final file = File('${dir.path}/$fileName');
          await file.writeAsString(content, flush: true);
          return file;
        }
      } catch (e) {
        debugPrint('Failed writing CSV to directory candidate: $e');
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
