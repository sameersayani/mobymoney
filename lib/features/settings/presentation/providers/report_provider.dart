import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobymoney/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:mobymoney/features/settings/data/report_repository.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository();
});

class ReportDownloadState {
  final bool isLoading;
  final File? downloadedFile;
  final String? errorMessage;

  const ReportDownloadState({
    this.isLoading = false,
    this.downloadedFile,
    this.errorMessage,
  });

  ReportDownloadState copyWith({
    bool? isLoading,
    File? downloadedFile,
    String? errorMessage,
  }) {
    return ReportDownloadState(
      isLoading: isLoading ?? this.isLoading,
      downloadedFile: downloadedFile ?? this.downloadedFile,
      errorMessage: errorMessage,
    );
  }
}

class ReportNotifier extends Notifier<ReportDownloadState> {
  @override
  ReportDownloadState build() {
    return const ReportDownloadState();
  }

  Future<File?> downloadReport({
    required int year,
    int? month,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(reportRepositoryProvider);
      final recentExpenses = ref.read(dashboardSummaryProvider).asData?.value.recentExpenses ?? [];
      final file = await repo.downloadExpenseReport(
        year: year,
        month: month,
        fallbackExpenses: recentExpenses,
      );
      state = state.copyWith(isLoading: false, downloadedFile: file);
      return file;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  void reset() {
    state = const ReportDownloadState();
  }
}

final reportNotifierProvider =
    NotifierProvider<ReportNotifier, ReportDownloadState>(() => ReportNotifier());
