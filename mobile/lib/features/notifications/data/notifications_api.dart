import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/pagination.dart';
import 'notification_models.dart';

final notificationsApiProvider =
    Provider<NotificationsApi>((ref) => NotificationsApi(ref.watch(dioProvider)));

class NotificationsApi {
  NotificationsApi(this._dio);

  final Dio _dio;

  Future<Paginated<AppNotification>> list({int page = 1, int perPage = 20}) =>
      guardApi(() async {
        final res = await _dio.get<Map<String, dynamic>>('/api/notifications',
            queryParameters: {'page': page, 'per_page': perPage});
        return Paginated.fromJson(res.data!, AppNotification.fromJson);
      });

  Future<int> unreadCount() => guardApi(() async {
        final res = await _dio
            .get<Map<String, dynamic>>('/api/notifications/unread-count');
        final data = res.data!['data'] as Map<String, dynamic>? ?? const {};
        return (data['count'] as num?)?.toInt() ?? 0;
      });

  Future<void> markRead(String id) =>
      guardApi(() => _dio.patch('/api/notifications/$id/read'));

  Future<void> markAllRead() =>
      guardApi(() => _dio.patch('/api/notifications/read-all'));
}
