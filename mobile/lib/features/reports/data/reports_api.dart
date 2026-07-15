import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../dashboard/data/dashboard_models.dart';
import 'report_models.dart';

final reportsApiProvider =
    Provider<ReportsApi>((ref) => ReportsApi(ref.watch(dioProvider)));

/// Filter periode laporan; nilai period mengikuti backend
/// (`daily` | `weekly` | `monthly`).
class ReportRange {
  const ReportRange({required this.period, this.start, this.end});

  final String period;
  final String? start;
  final String? end;

  Map<String, dynamic> toQuery() => {
        'period': period,
        'start': ?start,
        'end': ?end,
      };

  @override
  bool operator ==(Object other) =>
      other is ReportRange &&
      other.period == period &&
      other.start == start &&
      other.end == end;

  @override
  int get hashCode => Object.hash(period, start, end);
}

class ReportsApi {
  ReportsApi(this._dio);

  final Dio _dio;

  /// Raw array `[{date, revenue, count}]`.
  Future<List<RevenueDataPoint>> revenue(ReportRange range) =>
      guardApi(() async {
        final res = await _dio.get<List>('/api/reports/revenue',
            queryParameters: range.toQuery());
        return res.data!
            .map((e) => RevenueDataPoint.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  Future<ProfitReport> profit(ReportRange range) => guardApi(() async {
        final res = await _dio.get<Map<String, dynamic>>('/api/reports/profit',
            queryParameters: range.toQuery());
        return ProfitReport.fromJson(res.data!);
      });
}

final revenueReportProvider =
    FutureProvider.family<List<RevenueDataPoint>, ReportRange>(
        (ref, range) => ref.watch(reportsApiProvider).revenue(range));

final profitReportProvider = FutureProvider.family<ProfitReport, ReportRange>(
    (ref, range) => ref.watch(reportsApiProvider).profit(range));
