import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../customers/data/customer_models.dart';
import '../data/po_models.dart';
import '../data/purchase_orders_api.dart';
import '../providers/po_providers.dart';
import 'widgets/entity_pickers.dart';

/// Form create (po == null) / edit (po != null) purchase order.
/// [initialCustomer] dipakai saat membuat PO dari halaman detail pelanggan.
class PoFormScreen extends ConsumerStatefulWidget {
  const PoFormScreen({super.key, this.po, this.initialCustomer});

  final PurchaseOrder? po;
  final Customer? initialCustomer;

  @override
  ConsumerState<PoFormScreen> createState() => _PoFormScreenState();
}

class _ItemDraft {
  _ItemDraft({
    this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.notes,
  });

  String? productId;
  String productName;
  double quantity;
  double unitPrice;
  String? notes;

  double get subtotal => quantity * unitPrice;

  PoItemInput toInput() => PoItemInput(
        productId: productId,
        productName: productName,
        quantity: quantity,
        unitPrice: unitPrice,
        notes: notes,
      );
}

class _PoFormScreenState extends ConsumerState<PoFormScreen> {
  static final _apiDate = DateFormat('yyyy-MM-dd');

  late Customer? _customer = widget.po?.customer ?? widget.initialCustomer;
  late DateTime _orderDate = widget.po != null
      ? (DateTime.tryParse(widget.po!.orderDate) ?? DateTime.now())
      : DateTime.now();
  late DateTime _deliveryDate = widget.po != null
      ? (DateTime.tryParse(widget.po!.deliveryDate) ?? DateTime.now())
      : DateTime.now().add(const Duration(days: 1));
  late final List<_ItemDraft> _items = widget.po == null
      ? []
      : widget.po!.items
          .map((i) => _ItemDraft(
                productId: i.productId,
                productName: i.productName,
                quantity: i.quantity,
                unitPrice: i.unitPrice,
                notes: i.notes,
              ))
          .toList();
  late final _discount = TextEditingController(
      text: (widget.po?.discount ?? 0) > 0
          ? widget.po!.discount.toStringAsFixed(0)
          : '');
  late final _tax = TextEditingController(
      text: (widget.po?.tax ?? 0) > 0
          ? widget.po!.tax.toStringAsFixed(0)
          : '');
  late final _shipping = TextEditingController(
      text: (widget.po?.shippingCost ?? 0) > 0
          ? widget.po!.shippingCost.toStringAsFixed(0)
          : '');
  late final _notes = TextEditingController(text: widget.po?.notes);
  bool _submitting = false;

  bool get _isEdit => widget.po != null;

  double get _subtotal =>
      _items.fold(0, (sum, item) => sum + item.subtotal);

  double _parseAmount(TextEditingController c) =>
      double.tryParse(c.text.replaceAll('.', '')) ?? 0;

  double get _total => (_subtotal -
          _parseAmount(_discount) +
          _parseAmount(_tax) +
          _parseAmount(_shipping))
      .clamp(0, double.infinity);

  @override
  void dispose() {
    _discount.dispose();
    _tax.dispose();
    _shipping.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickCustomer() async {
    final customer = await showCustomerPicker(context);
    if (customer != null) setState(() => _customer = customer);
  }

  Future<void> _pickDate({required bool isDelivery}) async {
    final initial = isDelivery ? _deliveryDate : _orderDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: isDelivery ? DateTime.now() : DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        if (isDelivery) {
          _deliveryDate = picked;
        } else {
          _orderDate = picked;
        }
      });
    }
  }

  Future<void> _addOrEditItem({_ItemDraft? existing}) async {
    final result = await showModalBottomSheet<_ItemDraft>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ItemSheet(existing: existing),
    );
    if (result == null) return;
    setState(() {
      if (existing != null) {
        final index = _items.indexOf(existing);
        _items[index] = result;
      } else {
        _items.add(result);
      }
    });
  }

  Future<void> _submit() async {
    if (_customer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih pelanggan terlebih dahulu.')));
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tambahkan minimal 1 item.')));
      return;
    }
    setState(() => _submitting = true);
    final input = PoInput(
      customerId: _customer!.id,
      orderDate: _apiDate.format(_orderDate),
      deliveryDate: _apiDate.format(_deliveryDate),
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      discount: _parseAmount(_discount),
      tax: _parseAmount(_tax),
      shippingCost: _parseAmount(_shipping),
      items: _items.map((i) => i.toInput()).toList(),
    );
    try {
      final api = ref.read(purchaseOrdersApiProvider);
      final PurchaseOrder saved;
      if (_isEdit) {
        saved = await api.update(widget.po!.id, input);
        ref.invalidate(poDetailProvider(widget.po!.id));
      } else {
        saved = await api.create(input);
      }
      ref.read(poListProvider.notifier).refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEdit
              ? 'PO ${saved.poNumber} diperbarui.'
              : 'PO ${saved.poNumber} berhasil dibuat.')));
      if (_isEdit) {
        context.pop();
      } else {
        context.pushReplacement('/po/${saved.id}');
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit PO' : 'Buat PO Baru')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Pelanggan
          const _SectionTitle('Pelanggan'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline,
                  color: AppColors.primary),
              title: Text(_customer?.name ?? 'Pilih pelanggan…'),
              subtitle: _customer?.phone?.isNotEmpty == true
                  ? Text(_customer!.phone!)
                  : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickCustomer,
            ),
          ),
          const SizedBox(height: 16),
          // Tanggal
          const _SectionTitle('Tanggal'),
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: 'Tgl Order',
                  value: _orderDate,
                  onTap: () => _pickDate(isDelivery: false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateField(
                  label: 'Tgl Kirim',
                  value: _deliveryDate,
                  onTap: () => _pickDate(isDelivery: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Items
          Row(
            children: [
              const Expanded(child: _SectionTitle('Item Pesanan')),
              TextButton.icon(
                onPressed: () => _addOrEditItem(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah'),
              ),
            ],
          ),
          if (_items.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Belum ada item. Tekan "Tambah" untuk memilih produk '
                  'atau mengisi item manual.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          for (final item in _items)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(item.productName),
                subtitle: Text(
                    '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} × ${formatRupiah(item.unitPrice)} = ${formatRupiah(item.subtotal)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => setState(() => _items.remove(item)),
                ),
                onTap: () => _addOrEditItem(existing: item),
              ),
            ),
          const SizedBox(height: 16),
          // Biaya tambahan
          const _SectionTitle('Biaya Tambahan'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _discount,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                      labelText: 'Diskon', prefixText: 'Rp '),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _tax,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                      labelText: 'Pajak', prefixText: 'Rp '),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _shipping,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
                labelText: 'Ongkos Kirim', prefixText: 'Rp '),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Catatan'),
          ),
          const SizedBox(height: 90),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    Text(formatRupiah(_total),
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(_isEdit ? 'Simpan' : 'Buat PO'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w700)),
      );
}

class _DateField extends StatelessWidget {
  const _DateField(
      {required this.label, required this.value, required this.onTap});

  final String label;
  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(formatDate(value)),
      ),
    );
  }
}

/// Bottom sheet tambah/edit item: pilih produk (auto isi harga) atau manual.
class _ItemSheet extends StatefulWidget {
  const _ItemSheet({this.existing});

  final _ItemDraft? existing;

  @override
  State<_ItemSheet> createState() => _ItemSheetState();
}

class _ItemSheetState extends State<_ItemSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _productId;
  late final _name =
      TextEditingController(text: widget.existing?.productName);
  late final _qty = TextEditingController(
      text: widget.existing == null
          ? '1'
          : (widget.existing!.quantity % 1 == 0
              ? widget.existing!.quantity.toInt().toString()
              : widget.existing!.quantity.toString()));
  late final _price = TextEditingController(
      text: widget.existing == null
          ? ''
          : widget.existing!.unitPrice.toStringAsFixed(0));
  late final _itemNotes =
      TextEditingController(text: widget.existing?.notes);

  @override
  void initState() {
    super.initState();
    _productId = widget.existing?.productId;
  }

  @override
  void dispose() {
    _name.dispose();
    _qty.dispose();
    _price.dispose();
    _itemNotes.dispose();
    super.dispose();
  }

  Future<void> _pickProduct() async {
    final product = await showProductPicker(context);
    if (product == null) return;
    setState(() {
      _productId = product.id;
      _name.text = product.name;
      if (_price.text.isEmpty || widget.existing == null) {
        _price.text = product.price.toStringAsFixed(0);
      }
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_ItemDraft(
      productId: _productId,
      productName: _name.text.trim(),
      quantity: double.parse(_qty.text.replaceAll(',', '.')),
      unitPrice: double.parse(_price.text.replaceAll('.', '')),
      notes:
          _itemNotes.text.trim().isEmpty ? null : _itemNotes.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.existing == null ? 'Tambah Item' : 'Edit Item',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickProduct,
              icon: const Icon(Icons.inventory_2_outlined, size: 18),
              label: const Text('Pilih dari Daftar Produk'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nama Item *'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Nama item wajib diisi'
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qty,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Qty *'),
                    validator: (v) {
                      final parsed =
                          double.tryParse((v ?? '').replaceAll(',', '.'));
                      if (parsed == null || parsed <= 0) {
                        return 'Qty tidak valid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Harga Satuan *', prefixText: 'Rp '),
                    validator: (v) {
                      final parsed =
                          double.tryParse((v ?? '').replaceAll('.', ''));
                      if (parsed == null || parsed < 0) {
                        return 'Harga tidak valid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _itemNotes,
              decoration:
                  const InputDecoration(labelText: 'Catatan item'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _save,
              child: const Text('Simpan Item'),
            ),
          ],
        ),
      ),
    );
  }
}
