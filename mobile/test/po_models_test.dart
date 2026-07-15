import 'package:flutter_test/flutter_test.dart';
import 'package:po_scheduler_mobile/core/api/pagination.dart';
import 'package:po_scheduler_mobile/features/purchase_orders/data/po_models.dart';

void main() {
  group('PurchaseOrder.fromJson', () {
    test('parse payload lengkap dengan decimal Laravel sebagai string', () {
      final po = PurchaseOrder.fromJson({
        'id': 'po-1',
        'po_number': 'PO-2026-0001',
        'customer_id': 'c-1',
        'customer': {
          'id': 'c-1',
          'name': 'Ibu Sari',
          'phone': '0812000111',
          'tags': <String>[],
          'total_orders': 5,
          'total_revenue': '2500000.00',
        },
        'order_date': '2026-07-10',
        'delivery_date': '2026-07-20',
        'status': 'in_progress',
        'payment_status': 'dp',
        'dp_amount': '50000.00',
        'paid_amount': '50000.00',
        'subtotal': '150000.00',
        'discount': '0.00',
        'tax': '0.00',
        'shipping_cost': '10000.00',
        'total': '160000.00',
        'notes': null,
        'payment_method': 'Transfer BCA',
        'items': [
          {
            'id': 'i-1',
            'product_id': null,
            'product_name': 'Kue Lapis',
            'quantity': '10.00',
            'unit_price': '15000.00',
            'subtotal': '150000.00',
            'notes': null,
            'sort_order': 0,
          },
        ],
        'status_history': [
          {
            'id': 'h-1',
            'from_status': 'confirmed',
            'to_status': 'in_progress',
            'changed_at': '2026-07-11T10:00:00Z',
          },
        ],
      });

      expect(po.status, PoStatus.inProgress);
      expect(po.paymentStatus, PaymentStatus.dp);
      expect(po.total, 160000.0);
      expect(po.shippingCost, 10000.0);
      expect(po.customer?.totalRevenue, 2500000.0);
      expect(po.items.single.quantity, 10.0);
      expect(po.items.single.unitPrice, 15000.0);
      expect(po.statusHistory.single.fromStatus, PoStatus.confirmed);
    });

    test('angka numerik biasa (bukan string) juga terbaca', () {
      final item = PurchaseOrderItem.fromJson({
        'product_name': 'Brownies',
        'quantity': 2,
        'unit_price': 45000,
        'subtotal': 90000,
      });
      expect(item.subtotal, 90000.0);
    });
  });

  group('PoStatus transisi (mengikuti backend)', () {
    test('draft → confirmed/cancelled', () {
      expect(PoStatus.draft.allowedTransitions,
          [PoStatus.confirmed, PoStatus.cancelled]);
    });
    test('completed & cancelled final', () {
      expect(PoStatus.completed.allowedTransitions, isEmpty);
      expect(PoStatus.cancelled.isFinal, isTrue);
    });
    test('apiValue in_progress memakai snake_case', () {
      expect(PoStatus.inProgress.apiValue, 'in_progress');
    });
  });

  test('PoInput.toJson memakai snake_case dan menyertakan items', () {
    const input = PoInput(
      customerId: 'c-1',
      orderDate: '2026-07-14',
      deliveryDate: '2026-07-20',
      discount: 5000,
      items: [
        PoItemInput(productName: 'Kue Lapis', quantity: 2, unitPrice: 15000),
      ],
    );
    final json = input.toJson();
    expect(json['customer_id'], 'c-1');
    expect(json['delivery_date'], '2026-07-20');
    final items = json['items'] as List;
    expect((items.first as Map)['product_name'], 'Kue Lapis');
    expect((items.first as Map)['unit_price'], 15000);
  });

  test('PoFilters.toQuery hanya mengirim filter yang terisi', () {
    const filters = PoFilters(status: PoStatus.inProgress, search: 'sari');
    final query = filters.toQuery();
    expect(query, {'search': 'sari', 'status': 'in_progress'});
  });

  test('Paginated.fromJson membaca meta Laravel', () {
    final page = Paginated.fromJson({
      'data': [
        {'product_name': 'A', 'quantity': 1, 'unit_price': 100},
      ],
      'meta': {'current_page': 1, 'last_page': 3, 'per_page': 20, 'total': 55},
    }, PurchaseOrderItem.fromJson);

    expect(page.items, hasLength(1));
    expect(page.meta.total, 55);
    expect(page.hasMore, isTrue);
  });
}
