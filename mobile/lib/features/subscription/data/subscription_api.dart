import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import 'subscription_models.dart';

final subscriptionApiProvider =
    Provider<SubscriptionApi>((ref) => SubscriptionApi(ref.watch(dioProvider)));

class SubscriptionApi {
  SubscriptionApi(this._dio);

  final Dio _dio;

  Future<SubscriptionStatus> status() => guardApi(() async {
        final res =
            await _dio.get<Map<String, dynamic>>('/api/subscription/status');
        return SubscriptionStatus.fromJson(res.data!);
      });

  Future<void> requestUpgrade({String? note}) =>
      guardApi(() => _dio.post('/api/subscription/request',
          data: {'payment_proof_note': ?note}));

  Future<QuotaUsage> quotaUsage() => guardApi(() async {
        final res = await _dio.get<Map<String, dynamic>>('/api/quota/usage');
        return QuotaUsage.fromJson(res.data!['data'] as Map<String, dynamic>);
      });

  Future<Uint8List> downloadInvoice(String id) => guardApi(() async {
        final res = await _dio.get<List<int>>('/api/subscription/$id/invoice',
            options: Options(responseType: ResponseType.bytes));
        return Uint8List.fromList(res.data!);
      });
}

final subscriptionStatusProvider = FutureProvider<SubscriptionStatus>(
    (ref) => ref.watch(subscriptionApiProvider).status());

final quotaUsageProvider = FutureProvider<QuotaUsage>(
    (ref) => ref.watch(subscriptionApiProvider).quotaUsage());
