import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../data/product_models.dart';
import '../providers/products_provider.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.product?.name);
  late final _sku = TextEditingController(text: widget.product?.sku);
  late final _unit = TextEditingController(text: widget.product?.unit ?? 'pcs');
  late final _price = TextEditingController(
      text: widget.product == null
          ? ''
          : widget.product!.price.toStringAsFixed(0));
  late final _cost = TextEditingController(
      text: widget.product?.cost == null
          ? ''
          : widget.product!.cost!.toStringAsFixed(0));
  late final _description =
      TextEditingController(text: widget.product?.description);
  late bool _isActive = widget.product?.isActive ?? true;
  late bool _showInCatalog = widget.product?.showInCatalog ?? false;
  String? _pickedImagePath;
  bool _submitting = false;
  Map<String, List<String>> _fieldErrors = const {};

  bool get _isEdit => widget.product != null;

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _unit.dispose();
    _price.dispose();
    _cost.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _pickedImagePath = picked.path);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _fieldErrors = const {};
    });
    final input = ProductInput(
      name: _name.text.trim(),
      sku: _sku.text.trim().isEmpty ? null : _sku.text.trim(),
      unit: _unit.text.trim().isEmpty ? 'pcs' : _unit.text.trim(),
      price: double.tryParse(_price.text.replaceAll('.', '')) ?? 0,
      cost: _cost.text.trim().isEmpty
          ? null
          : double.tryParse(_cost.text.replaceAll('.', '')),
      description:
          _description.text.trim().isEmpty ? null : _description.text.trim(),
      isActive: _isActive,
      showInCatalog: _showInCatalog,
    );
    try {
      final notifier = ref.read(productListProvider.notifier);
      if (_isEdit) {
        await notifier.update(widget.product!.id, input,
            imagePath: _pickedImagePath);
      } else {
        await notifier.create(input, imagePath: _pickedImagePath);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEdit
            ? 'Produk berhasil diperbarui.'
            : 'Produk berhasil ditambahkan.'),
      ));
      context.pop();
    } on ApiException catch (e) {
      setState(() => _fieldErrors = e.fieldErrors);
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
      appBar: AppBar(title: Text(_isEdit ? 'Edit Produk' : 'Tambah Produk')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: _ImagePreview(
                  pickedPath: _pickedImagePath,
                  existingUrl: widget.product?.imageUrl,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Nama Produk *',
                errorText: _fieldErrors['name']?.first,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Nama produk wajib diisi'
                  : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _sku,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'SKU',
                      errorText: _fieldErrors['sku']?.first,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _unit,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                        labelText: 'Satuan *', hintText: 'pcs / kg / box'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Satuan wajib diisi'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Harga Jual *',
                      prefixText: 'Rp ',
                      errorText: _fieldErrors['price']?.first,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Harga wajib diisi';
                      }
                      if (double.tryParse(v.replaceAll('.', '')) == null) {
                        return 'Harga tidak valid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cost,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                        labelText: 'HPP / Modal', prefixText: 'Rp '),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Produk aktif'),
              subtitle: const Text('Produk nonaktif tidak bisa dipilih di PO'),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tampilkan di katalog online'),
              value: _showInCatalog,
              onChanged: (v) => setState(() => _showInCatalog = v),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(_isEdit ? 'Simpan Perubahan' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({this.pickedPath, this.existingUrl});

  final String? pickedPath;
  final String? existingUrl;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (pickedPath != null) {
      child = Image.file(File(pickedPath!),
          width: 120, height: 120, fit: BoxFit.cover);
    } else if (existingUrl != null && existingUrl!.isNotEmpty) {
      child = CachedNetworkImage(
          imageUrl: existingUrl!, width: 120, height: 120, fit: BoxFit.cover);
    } else {
      child = Container(
        width: 120,
        height: 120,
        color: AppColors.primary.withValues(alpha: 0.08),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
            SizedBox(height: 6),
            Text('Foto Produk',
                style: TextStyle(fontSize: 12, color: AppColors.primary)),
          ],
        ),
      );
    }
    return ClipRRect(borderRadius: BorderRadius.circular(12), child: child);
  }
}
