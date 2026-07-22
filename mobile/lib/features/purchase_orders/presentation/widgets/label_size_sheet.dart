import 'package:flutter/material.dart';

import '../../data/purchase_orders_api.dart';

/// Bottom sheet pemilih ukuran label. Mengembalikan [PoLabelSize] yang dipilih
/// atau `null` bila dibatalkan. Dipakai bersama di detail & list PO.
Future<PoLabelSize?> showLabelSizeSheet(BuildContext context) {
  return showModalBottomSheet<PoLabelSize>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text('Pilih ukuran label',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          for (final size in PoLabelSize.values)
            ListTile(
              leading: const Icon(Icons.label_outline),
              title: Text(size.label),
              onTap: () => Navigator.of(ctx).pop(size),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
