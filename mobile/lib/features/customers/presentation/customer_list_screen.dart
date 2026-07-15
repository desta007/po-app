import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/async_states.dart';
import '../providers/customers_provider.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() =>
      _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(customerListProvider.notifier).setSearch(value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerListProvider);
    final notifier = ref.read(customerListProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Pelanggan')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/customers/create'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Cari nama / telepon pelanggan…',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: Builder(builder: (context) {
              if (state.isLoading) return const LoadingView();
              if (state.error != null) {
                return ErrorRetryView(
                    message: state.error!, onRetry: notifier.refresh);
              }
              if (state.isEmpty) {
                return const EmptyView(
                  icon: Icons.people_outline,
                  title: 'Belum ada pelanggan',
                  subtitle: 'Tambahkan pelanggan pertama Anda dengan tombol +',
                );
              }
              return RefreshIndicator(
                onRefresh: notifier.refresh,
                child: InfiniteScrollListener(
                  onLoadMore: notifier.loadMore,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount:
                        state.items.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.items.length) {
                        return const LoadMoreIndicator();
                      }
                      final customer = state.items[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.12),
                          child: Text(
                            customer.name.isNotEmpty
                                ? customer.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: AppColors.primary),
                          ),
                        ),
                        title: Text(customer.name),
                        subtitle: Text(
                          customer.phone?.isNotEmpty == true
                              ? customer.phone!
                              : (customer.email ?? '-'),
                        ),
                        trailing: Text(
                          '${customer.totalOrders} PO',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        ),
                        onTap: () => context.push('/customers/${customer.id}'),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
