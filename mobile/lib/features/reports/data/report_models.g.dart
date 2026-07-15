// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfitDataPoint _$ProfitDataPointFromJson(Map<String, dynamic> json) =>
    _ProfitDataPoint(
      date: json['date'] as String,
      revenue: json['revenue'] == null
          ? 0
          : const FlexDouble().fromJson(json['revenue']),
      totalCost: json['total_cost'] == null
          ? 0
          : const FlexDouble().fromJson(json['total_cost']),
      profit: json['profit'] == null
          ? 0
          : const FlexDouble().fromJson(json['profit']),
      orderCount: json['order_count'] == null
          ? 0
          : const FlexInt().fromJson(json['order_count']),
    );

Map<String, dynamic> _$ProfitDataPointToJson(_ProfitDataPoint instance) =>
    <String, dynamic>{
      'date': instance.date,
      'revenue': const FlexDouble().toJson(instance.revenue),
      'total_cost': const FlexDouble().toJson(instance.totalCost),
      'profit': const FlexDouble().toJson(instance.profit),
      'order_count': const FlexInt().toJson(instance.orderCount),
    };

_ProfitSummary _$ProfitSummaryFromJson(Map<String, dynamic> json) =>
    _ProfitSummary(
      totalRevenue: json['total_revenue'] == null
          ? 0
          : const FlexDouble().fromJson(json['total_revenue']),
      totalCost: json['total_cost'] == null
          ? 0
          : const FlexDouble().fromJson(json['total_cost']),
      totalProfit: json['total_profit'] == null
          ? 0
          : const FlexDouble().fromJson(json['total_profit']),
      totalOrders: json['total_orders'] == null
          ? 0
          : const FlexInt().fromJson(json['total_orders']),
    );

Map<String, dynamic> _$ProfitSummaryToJson(_ProfitSummary instance) =>
    <String, dynamic>{
      'total_revenue': const FlexDouble().toJson(instance.totalRevenue),
      'total_cost': const FlexDouble().toJson(instance.totalCost),
      'total_profit': const FlexDouble().toJson(instance.totalProfit),
      'total_orders': const FlexInt().toJson(instance.totalOrders),
    };

_ProfitTopProduct _$ProfitTopProductFromJson(Map<String, dynamic> json) =>
    _ProfitTopProduct(
      name: json['name'] as String,
      totalQty: json['total_qty'] == null
          ? 0
          : const FlexDouble().fromJson(json['total_qty']),
      revenue: json['revenue'] == null
          ? 0
          : const FlexDouble().fromJson(json['revenue']),
      cost: json['cost'] == null
          ? 0
          : const FlexDouble().fromJson(json['cost']),
      profit: json['profit'] == null
          ? 0
          : const FlexDouble().fromJson(json['profit']),
    );

Map<String, dynamic> _$ProfitTopProductToJson(_ProfitTopProduct instance) =>
    <String, dynamic>{
      'name': instance.name,
      'total_qty': const FlexDouble().toJson(instance.totalQty),
      'revenue': const FlexDouble().toJson(instance.revenue),
      'cost': const FlexDouble().toJson(instance.cost),
      'profit': const FlexDouble().toJson(instance.profit),
    };

_ProfitReport _$ProfitReportFromJson(Map<String, dynamic> json) =>
    _ProfitReport(
      chart:
          (json['chart'] as List<dynamic>?)
              ?.map((e) => ProfitDataPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      summary: json['summary'] == null
          ? null
          : ProfitSummary.fromJson(json['summary'] as Map<String, dynamic>),
      topProducts:
          (json['top_products'] as List<dynamic>?)
              ?.map((e) => ProfitTopProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ProfitReportToJson(_ProfitReport instance) =>
    <String, dynamic>{
      'chart': instance.chart.map((e) => e.toJson()).toList(),
      'summary': instance.summary?.toJson(),
      'top_products': instance.topProducts.map((e) => e.toJson()).toList(),
    };
