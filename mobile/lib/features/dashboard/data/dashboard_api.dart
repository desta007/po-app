import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import 'dashboard_models.dart';

final dashboardApiProvider =
    Provider<DashboardApi>((ref) => DashboardApi(ref.watch(dioProvider)));

/// Endpoint dashboard mengembalikan raw JSON tanpa wrapper `data`.
class DashboardApi {
  DashboardApi(this._dio);

  final Dio _dio;

  Future<TodaySummary> todaySummary() => guardApi(() async {
        final res = await _dio
            .get<Map<String, dynamic>>('/api/dashboard/today-summary');
        return TodaySummary.fromJson(res.data!);
      });

  Future<List<RevenueDataPoint>> revenueChart() => guardApi(() async {
        final res = await _dio.get<List>('/api/dashboard/revenue-chart');
        return res.data!
            .map((e) => RevenueDataPoint.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  Future<List<TopCustomer>> topCustomers() => guardApi(() async {
        final res = await _dio.get<List>('/api/dashboard/top-customers');
        return res.data!
            .map((e) => TopCustomer.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  Future<List<TopProduct>> topProducts() => guardApi(() async {
        final res = await _dio.get<List>('/api/dashboard/top-products');
        return res.data!
            .map((e) => TopProduct.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  Future<PendingPayment> pendingPayments() => guardApi(() async {
        final res = await _dio
            .get<Map<String, dynamic>>('/api/dashboard/pending-payments');
        return PendingPayment.fromJson(res.data!);
      });
}

final todaySummaryProvider = FutureProvider<TodaySummary>(
    (ref) => ref.watch(dashboardApiProvider).todaySummary());

final revenueChartProvider = FutureProvider<List<RevenueDataPoint>>(
    (ref) => ref.watch(dashboardApiProvider).revenueChart());

final topCustomersProvider = FutureProvider<List<TopCustomer>>(
    (ref) => ref.watch(dashboardApiProvider).topCustomers());

final topProductsProvider = FutureProvider<List<TopProduct>>(
    (ref) => ref.watch(dashboardApiProvider).topProducts());

final pendingPaymentsProvider = FutureProvider<PendingPayment>(
    (ref) => ref.watch(dashboardApiProvider).pendingPayments());
