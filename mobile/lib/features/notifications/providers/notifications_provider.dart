import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../shared/providers/paged_list.dart';
import '../data/notification_models.dart';
import '../data/notifications_api.dart';

final unreadCountProvider = FutureProvider<int>(
    (ref) => ref.watch(notificationsApiProvider).unreadCount());

final notificationListProvider = NotifierProvider<NotificationListNotifier,
    PagedListState<AppNotification>>(NotificationListNotifier.new);

class NotificationListNotifier extends Notifier<PagedListState<AppNotification>> {
  int _requestId = 0;

  NotificationsApi get _api => ref.read(notificationsApiProvider);

  @override
  PagedListState<AppNotification> build() {
    Future.microtask(refresh);
    return const PagedListState(isLoading: true);
  }

  Future<void> refresh() async {
    final id = ++_requestId;
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final result = await _api.list(page: 1);
      if (id != _requestId) return;
      state = PagedListState.firstPage(result);
    } on ApiException catch (e) {
      if (id != _requestId) return;
      state = state.copyWith(isLoading: false, error: () => e.message);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    final id = ++_requestId;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.list(page: state.page + 1);
      if (id != _requestId) return;
      state = state.appendPage(result);
    } on ApiException {
      if (id != _requestId) return;
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> markRead(AppNotification notification) async {
    if (!notification.isUnread) return;
    await _api.markRead(notification.id);
    state = state.copyWith(
      items: [
        for (final n in state.items)
          n.id == notification.id
              ? n.copyWith(readAt: DateTime.now().toIso8601String())
              : n,
      ],
    );
    ref.invalidate(unreadCountProvider);
  }

  Future<void> markAllRead() async {
    await _api.markAllRead();
    final now = DateTime.now().toIso8601String();
    state = state.copyWith(
      items: [
        for (final n in state.items)
          n.isUnread ? n.copyWith(readAt: now) : n,
      ],
    );
    ref.invalidate(unreadCountProvider);
  }
}
