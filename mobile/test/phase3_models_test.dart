import 'package:flutter_test/flutter_test.dart';
import 'package:po_scheduler_mobile/features/calendar/data/calendar_models.dart';
import 'package:po_scheduler_mobile/features/dashboard/data/dashboard_models.dart';
import 'package:po_scheduler_mobile/features/notifications/data/notification_models.dart';
import 'package:po_scheduler_mobile/features/purchase_orders/data/po_models.dart';
import 'package:po_scheduler_mobile/features/reports/data/report_models.dart';

void main() {
  test('TodaySummary parse raw JSON dashboard (tanpa wrapper data)', () {
    final s = TodaySummary.fromJson({
      'total_po': 3,
      'po_change': '↑ 50% dari kemarin',
      'po_change_up': true,
      'total_revenue': 1250000.0,
      'revenue_change': '↓ 10% dari bulan lalu',
      'revenue_change_up': false,
      'active_customers': 12,
      'customer_change': '+2 bulan ini',
      'customer_change_up': true,
      'total_orders_this_month': 20,
      'draft': 2,
      'confirmed': 5,
      'in_progress': 6,
      'completed': 7,
    });
    expect(s.totalPo, 3);
    expect(s.revenueChangeUp, isFalse);
    expect(s.inProgress, 6);
  });

  test('RevenueDataPoint: SUM PostgreSQL datang sebagai string', () {
    final p = RevenueDataPoint.fromJson(
        {'date': '2026-07-01', 'revenue': '350000.00', 'count': '4'});
    expect(p.revenue, 350000.0);
    expect(p.count, 4);
  });

  test('PendingPayment parse float murni', () {
    final p = PendingPayment.fromJson({
      'total_unpaid': 2,
      'total_dp': 1,
      'unpaid_amount': 500000.0,
      'dp_remaining_amount': 150000.0,
    });
    expect(p.unpaidAmount + p.dpRemainingAmount, 650000.0);
  });

  test('CalendarEvent parse extendedProps (camelCase key khusus)', () {
    final e = CalendarEvent.fromJson({
      'id': 'po-1',
      'title': 'PO-0001 - Ibu Sari',
      'start': '2026-07-20',
      'backgroundColor': '#2E75B6',
      'borderColor': '#2E75B6',
      'extendedProps': {
        'po_number': 'PO-0001',
        'customer_name': 'Ibu Sari',
        'status': 'confirmed',
        'payment_status': 'dp',
        'total': '750000.00',
      },
    });
    expect(e.props.poNumber, 'PO-0001');
    expect(e.props.status, PoStatus.confirmed);
    expect(e.props.total, 750000.0);
  });

  test('ProfitReport parse chart + summary + top_products', () {
    final r = ProfitReport.fromJson({
      'chart': [
        {
          'date': '2026-07',
          'revenue': '1000000.00',
          'total_cost': '600000.00',
          'profit': '400000.00',
          'order_count': '8',
        },
      ],
      'summary': {
        'total_revenue': '1000000.00',
        'total_cost': '600000.00',
        'total_profit': '400000.00',
        'total_orders': 8,
      },
      'top_products': [
        {
          'name': 'Kue Lapis',
          'total_qty': '40.00',
          'revenue': '600000.00',
          'cost': '350000.00',
          'profit': '250000.00',
        },
      ],
    });
    expect(r.chart.single.profit, 400000.0);
    expect(r.summary?.totalOrders, 8);
    expect(r.topProducts.single.profit, 250000.0);
  });

  test('ProfitSummary: SUM null saat tidak ada data → 0', () {
    final s = ProfitSummary.fromJson({
      'total_revenue': null,
      'total_cost': null,
      'total_profit': null,
      'total_orders': 0,
    });
    expect(s.totalRevenue, 0);
    expect(s.totalProfit, 0);
  });

  test('AppNotification unread/read', () {
    final unread = AppNotification.fromJson({
      'id': 'n-1',
      'title': 'PO Baru',
      'message': 'PO-0001 dibuat',
      'po_id': 'po-1',
      'read_at': null,
      'created_at': '2026-07-14T09:00:00Z',
    });
    expect(unread.isUnread, isTrue);
    expect(unread.copyWith(readAt: '2026-07-14T10:00:00Z').isUnread, isFalse);
  });
}
