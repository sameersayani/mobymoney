import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../data/repositories/analytics_repository.dart';
import '../../domain/models/chart_data_model.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository();
});

final chartDataProvider =
    AsyncNotifierProvider<ChartDataNotifier, ChartDataModel>(
  () => ChartDataNotifier(),
);

class ChartDataNotifier extends AsyncNotifier<ChartDataModel> {
  DateTime _currentDate = DateTime.now();

  @override
  Future<ChartDataModel> build() async {
    _currentDate = ref.watch(selectedDateProvider);
    return _fetchChartData(date: _currentDate);
  }

  Future<ChartDataModel> _fetchChartData({DateTime? date}) async {
    final targetDate = date ?? _currentDate;
    final repo = ref.read(analyticsRepositoryProvider);
    return await repo.getChartData(
      month: targetDate.month,
      year: targetDate.year,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchChartData(date: _currentDate));
  }
}
