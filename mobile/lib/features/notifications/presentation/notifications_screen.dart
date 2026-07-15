import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/async_states.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationListProvider);
    final notifier = ref.read(notificationListProvider.notifier);
    final hasUnread = state.items.any((n) => n.isUnread);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: notifier.markAllRead,
              child: const Text('Tandai semua',
                  style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Builder(builder: (context) {
        if (state.isLoading) return const LoadingView();
        if (state.error != null) {
          return ErrorRetryView(
              message: state.error!, onRetry: notifier.refresh);
        }
        if (state.isEmpty) {
          return const EmptyView(
            icon: Icons.notifications_none,
            title: 'Belum ada notifikasi',
          );
        }
        return RefreshIndicator(
          onRefresh: notifier.refresh,
          child: InfiniteScrollListener(
            onLoadMore: notifier.loadMore,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index >= state.items.length) {
                  return const LoadMoreIndicator();
                }
                final n = state.items[index];
                return ListTile(
                  tileColor: n.isUnread
                      ? AppColors.primary.withValues(alpha: 0.05)
                      : null,
                  leading: Icon(
                    n.isUnread
                        ? Icons.mark_email_unread_outlined
                        : Icons.drafts_outlined,
                    color: n.isUnread
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  title: Text(
                    n.title,
                    style: TextStyle(
                      fontWeight:
                          n.isUnread ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.message, maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      Text(
                        formatDateTimeString(n.createdAt),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  onTap: () {
                    notifier.markRead(n);
                    if (n.poId != null) context.push('/po/${n.poId}');
                  },
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
