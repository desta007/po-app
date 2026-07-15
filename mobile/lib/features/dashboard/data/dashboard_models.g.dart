// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TodaySummary _$TodaySummaryFromJson(Map<String, dynamic> json) =>
    _TodaySummary(
      totalPo: json['total_po'] == null
          ? 0
          : const FlexInt().fromJson(json['total_po']),
      poChange: json['po_change'] as String?,
      poChangeUp: json['po_change_up'] as bool? ?? true,
      totalRevenue: json['total_revenue'] == null
          ? 0
          : const FlexDouble().fromJson(json['total_revenue']),
      revenueChange: json['revenue_change'] as String?,
      revenueChangeUp: json['revenue_change_up'] as bool? ?? true,
      activeCustomers: json['active_customers'] == null
          ? 0
          : const FlexInt().fromJson(json['active_customers']),
      customerChange: json['customer_change'] as String?,
      totalOrdersThisMonth: json['total_orders_this_month'] == null
          ? 0
          : const FlexInt().fromJson(json['total_orders_this_month']),
      draft: json['draft'] == null
          ? 0
          : const FlexInt().fromJson(json['draft']),
      confirmed: json['confirmed'] == null
          ? 0
          : const FlexInt().fromJson(json['confirmed']),
      inProgress: json['in_progress'] == null
          ? 0
          : const FlexInt().fromJson(json['in_progress']),
      completed: json['completed'] == null
          ? 0
          : const FlexInt().fromJson(json['completed']),
    );

Map<String, dynamic> _$TodaySummaryToJson(_TodaySummary instance) =>
    <String, dynamic>{
      'total_po': const FlexInt().toJson(instance.totalPo),
      'po_change': instance.poChange,
      'po_change_up': instance.poChangeUp,
      'total_revenue': const FlexDouble().toJson(instance.totalRevenue),
      'revenue_change': instance.revenueChange,
      'revenue_change_up': instance.revenueChangeUp,
      'active_customers': const FlexInt().toJson(instance.activeCustomers),
      'customer_change': instance.customerChange,
      'total_orders_this_month': const FlexInt().toJson(
        instance.totalOrdersThisMonth,
      ),
      'draft': const FlexInt().toJson(instance.draft),
      'confirmed': const FlexInt().toJson(instance.confirmed),
      'in_progress': const FlexInt().toJson(instance.inProgress),
      'completed': const FlexInt().toJson(instance.completed),
    };

_RevenueDataPoint _$RevenueDataPointFromJson(Map<String, dynamic> json) =>
    _RevenueDataPoint(
      date: json['date'] as String,
      revenue: json['revenue'] == null
          ? 0
          : const FlexDouble().fromJson(json['revenue']),
      count: json['count'] == null
          ? 0
          : const FlexInt().fromJson(json['count']),
    );

Map<String, dynamic> _$RevenueDataPointToJson(_RevenueDataPoint instance) =>
    <String, dynamic>{
      'date': instance.date,
      'revenue': const FlexDouble().toJson(instance.revenue),
      'count': const FlexInt().toJson(instance.count),
    };

_TopCustomer _$TopCustomerFromJson(Map<String, dynamic> json) => _TopCustomer(
  id: json['id'] as String?,
  name: json['name'] as String,
  totalRevenue: json['total_revenue'] == null
      ? 0
      : const FlexDouble().fromJson(json['total_revenue']),
  totalOrders: json['total_orders'] == null
      ? 0
      : const FlexInt().fromJson(json['total_orders']),
);

Map<String, dynamic> _$TopCustomerToJson(_TopCustomer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'total_revenue': const FlexDouble().toJson(instance.totalRevenue),
      'total_orders': const FlexInt().toJson(instance.totalOrders),
    };

_TopProduct _$TopProductFromJson(Map<String, dynamic> json) => _TopProduct(
  id: json['id'] as String?,
  name: json['name'] as String,
  totalQty: json['total_qty'] == null
      ? 0
      : const FlexDouble().fromJson(json['total_qty']),
  totalRevenue: json['total_revenue'] == null
      ? 0
      : const FlexDouble().fromJson(json['total_revenue']),
);

Map<String, dynamic> _$TopProductToJson(_TopProduct instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'total_qty': const FlexDouble().toJson(instance.totalQty),
      'total_revenue': const FlexDouble().toJson(instance.totalRevenue),
    };

_PendingPayment _$PendingPaymentFromJson(Map<String, dynamic> json) =>
    _PendingPayment(
      totalUnpaid: json['total_unpaid'] == null
          ? 0
          : const FlexInt().fromJson(json['total_unpaid']),
      totalDp: json['total_dp'] == null
          ? 0
          : const FlexInt().fromJson(json['total_dp']),
      unpaidAmount: json['unpaid_amount'] == null
          ? 0
          : const FlexDouble().fromJson(json['unpaid_amount']),
      dpRemainingAmount: json['dp_remaining_amount'] == null
          ? 0
          : const FlexDouble().fromJson(json['dp_remaining_amount']),
    );

Map<String, dynamic> _$PendingPaymentToJson(
  _PendingPayment instance,
) => <String, dynamic>{
  'total_unpaid': const FlexInt().toJson(instance.totalUnpaid),
  'total_dp': const FlexInt().toJson(instance.totalDp),
  'unpaid_amount': const FlexDouble().toJson(instance.unpaidAmount),
  'dp_remaining_amount': const FlexDouble().toJson(instance.dpRemainingAmount),
};
