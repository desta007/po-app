import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../data/product_models.dart';
import '../data/products_api.dart';
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
  late final _category =
      TextEditingController(text: widget.product?.category);
  late final _description =
      TextEditingController(text: widget.product?.description);
  late bool _isActive = widget.product?.isActive ?? true;
  late bool _showInCatalog = widget.product?.showInCatalog ?? false;

  /// Gambar yang sudah tersimpan di server (mode edit). Bisa dihapus per item.
  late final List<String> _existingImages = _initialExistingImages();
  /// Gambar baru dari galeri yang belum diupload (path lokal).
  final List<String> _pickedImagePaths = [];
  bool _submitting = false;
  Map<String, List<String>> _fieldErrors = const {};

  bool get _isEdit => widget.product != null;

  List<String> _initialExistingImages() {
    final p = widget.product;
    if (p == null) return [];
    if (p.images.isNotEmpty) return List.of(p.images);
    if (p.imageUrl != null && p.imageUrl!.isNotEmpty) return [p.imageUrl!];
    return [];
  }

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _unit.dispose();
    _price.dispose();
    _cost.dispose();
    _category.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await ImagePicker().pickMultiImage(
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked.isNotEmpty) {
      setState(() => _pickedImagePaths.addAll(picked.map((x) => x.path)));
    }
  }

  Future<void> _removeExistingImage(String url) async {
    // Di mode edit hapus langsung di server; galeri mengikuti respons berikutnya.
    try {
      await ref.read(productsApiProvider).deleteImage(widget.product!.id,
          imageUrl: url);
      if (mounted) setState(() => _existingImages.remove(url));
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
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
      category:
          _category.text.trim().isEmpty ? null : _category.text.trim(),
      description:
          _description.text.trim().isEmpty ? null : _description.text.trim(),
      isActive: _isActive,
      showInCatalog: _showInCatalog,
    );
    try {
      final notifier = ref.read(productListProvider.notifier);
      if (_isEdit) {
        await notifier.update(widget.product!.id, input,
            imagePaths: _pickedImagePaths);
      } else {
        await notifier.create(input, imagePaths: _pickedImagePaths);
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
            _ImageGallery(
              existingImages: _existingImages,
              pickedPaths: _pickedImagePaths,
              onAdd: _pickImages,
              onRemoveExisting: _isEdit ? _removeExistingImage : null,
              onRemovePicked: (path) =>
                  setState(() => _pickedImagePaths.remove(path)),
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
              controller: _category,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                  labelText: 'Kategori', hintText: 'Cth: Makanan, Minuman'),
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

/// Galeri gambar produk: tampilkan gambar tersimpan + yang baru dipilih, plus
/// tombol tambah. Bisa upload >1 gambar; gambar pertama jadi gambar utama —
/// selaras dengan form produk di web.
class _ImageGallery extends StatelessWidget {
  const _ImageGallery({
    required this.existingImages,
    required this.pickedPaths,
    required this.onAdd,
    required this.onRemovePicked,
    this.onRemoveExisting,
  });

  final List<String> existingImages;
  final List<String> pickedPaths;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemovePicked;
  final ValueChanged<String>? onRemoveExisting;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gambar Produk',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        const Text(
          'Bisa upload lebih dari 1 gambar. Gambar pertama menjadi gambar utama.',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final url in existingImages)
              _Thumb(
                image: CachedNetworkImage(
                    imageUrl: url, width: 72, height: 72, fit: BoxFit.cover),
                onRemove: onRemoveExisting == null
                    ? null
                    : () => onRemoveExisting!(url),
              ),
            for (final path in pickedPaths)
              _Thumb(
                image: Image.file(File(path),
                    width: 72, height: 72, fit: BoxFit.cover),
                onRemove: () => onRemovePicked(path),
              ),
            _AddImageButton(onTap: onAdd),
          ],
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.image, this.onRemove});

  final Widget image;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(8), child: image),
        if (onRemove != null)
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                decoration: const BoxDecoration(
                    color: AppColors.danger, shape: BoxShape.circle),
                padding: const EdgeInsets.all(2),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

class _AddImageButton extends StatelessWidget {
  const _AddImageButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: AppColors.primary, size: 22),
            SizedBox(height: 4),
            Text('Tambah',
                style: TextStyle(fontSize: 10, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
