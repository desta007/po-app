import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../customers/data/customer_models.dart';
import '../../../customers/data/customers_api.dart';
import '../../../products/data/product_models.dart';
import '../../../products/data/products_api.dart';

/// Bottom sheet pencarian pelanggan. Return [Customer] yang dipilih.
Future<Customer?> showCustomerPicker(BuildContext context) =>
    showModalBottomSheet<Customer>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _SearchSheet<Customer>(kind: _PickerKind.customer),
    );

/// Bottom sheet pencarian produk aktif. Return [Product] yang dipilih.
Future<Product?> showProductPicker(BuildContext context) =>
    showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _SearchSheet<Product>(kind: _PickerKind.product),
    );

enum _PickerKind { customer, product }

class _SearchSheet<T> extends ConsumerStatefulWidget {
  const _SearchSheet({super.key, required this.kind});

  final _PickerKind kind;

  @override
  ConsumerState<_SearchSheet<T>> createState() => _SearchSheetState<T>();
}

class _SearchSheetState<T> extends ConsumerState<_SearchSheet<T>> {
  Timer? _debounce;
  String _query = '';
  bool _loading = true;
  String? _error;
  List<Object> _results = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final List<Object> items;
      if (widget.kind == _PickerKind.customer) {
        final page =
            await ref.read(customersApiProvider).list(search: _query);
        items = page.items;
      } else {
        final page = await ref
            .read(productsApiProvider)
            .list(search: _query, isActive: true);
        items = page.items;
      }
      if (mounted) {
        setState(() {
          _results = items;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    }
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _query = value.trim();
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCustomer = widget.kind == _PickerKind.customer;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              autofocus: true,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText:
                    isCustomer ? 'Cari pelanggan…' : 'Cari produk…',
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: Builder(builder: (context) {
              if (_loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_error != null) {
                return Center(child: Text(_error!));
              }
              if (_results.isEmpty) {
                return Center(
                  child: Text(
                    isCustomer
                        ? 'Pelanggan tidak ditemukan'
                        : 'Produk tidak ditemukan',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }
              return ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final item = _results[index];
                  if (item is Customer) {
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text(item.phone ?? item.email ?? '-'),
                      onTap: () => Navigator.of(context).pop(item),
                    );
                  }
                  final product = item as Product;
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text(
                        '${formatRupiah(product.price)} / ${product.unit}'),
                    onTap: () => Navigator.of(context).pop(product),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
