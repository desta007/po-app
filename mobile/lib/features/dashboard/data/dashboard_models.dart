import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/api/json_converters.dart';

part 'dashboard_models.freezed.dart';
part 'dashboard_models.g.dart';

/// Konversi longgar untuk COUNT/SUM PostgreSQL yang bisa datang
/// sebagai int, string, atau double.
class FlexInt implements JsonConverter<int, Object?> {
  const FlexInt();

  @override
  int fromJson(Object? json) => switch (json) {
        num n => n.toInt(),
        String s => int.tryParse(s) ?? double.tryParse(s)?.toInt() ?? 0,
        _ => 0,
      };

  @override
  Object toJson(int value) => value;
}

/// Response `/api/dashboard/today-summary` (raw JSON, tanpa wrapper).
@freezed
abstract class TodaySummary with _$TodaySummary {
  const factory TodaySummary({
    @FlexInt() @Default(0) int totalPo,
    String? poChange,
    @Default(true) bool poChangeUp,
    @FlexDouble() @Default(0) double totalRevenue,
    String? revenueChange,
    @Default(true) bool revenueChangeUp,
    @FlexInt() @Default(0) int activeCustomers,
    String? customerChange,
    @FlexInt() @Default(0) int totalOrdersThisMonth,
    @FlexInt() @Default(0) int draft,
    @FlexInt() @Default(0) int confirmed,
    @FlexInt() @Default(0) int inProgress,
    @FlexInt() @Default(0) int completed,
  }) = _TodaySummary;

  factory TodaySummary.fromJson(Map<String, dynamic> json) =>
      _$TodaySummaryFromJson(json);
}

@freezed
abstract class RevenueDataPoint with _$RevenueDataPoint {
  const factory RevenueDataPoint({
    required String date,
    @FlexDouble() @Default(0) double revenue,
    @FlexInt() @Default(0) int count,
  }) = _RevenueDataPoint;

  factory RevenueDataPoint.fromJson(Map<String, dynamic> json) =>
      _$RevenueDataPointFromJson(json);
}

@freezed
abstract class TopCustomer with _$TopCustomer {
  const factory TopCustomer({
    String? id,
    required String name,
    @FlexDouble() @Default(0) double totalRevenue,
    @FlexInt() @Default(0) int totalOrders,
  }) = _TopCustomer;

  factory TopCustomer.fromJson(Map<String, dynamic> json) =>
      _$TopCustomerFromJson(json);
}

@freezed
abstract class TopProduct with _$TopProduct {
  const factory TopProduct({
    String? id,
    required String name,
    @FlexDouble() @Default(0) double totalQty,
    @FlexDouble() @Default(0) double totalRevenue,
  }) = _TopProduct;

  factory TopProduct.fromJson(Map<String, dynamic> json) =>
      _$TopProductFromJson(json);
}

@freezed
abstract class PendingPayment with _$PendingPayment {
  const factory PendingPayment({
    @FlexInt() @Default(0) int totalUnpaid,
    @FlexInt() @Default(0) int totalDp,
    @FlexDouble() @Default(0) double unpaidAmount,
    @FlexDouble() @Default(0) double dpRemainingAmount,
  }) = _PendingPayment;

  factory PendingPayment.fromJson(Map<String, dynamic> json) =>
      _$PendingPaymentFromJson(json);
}
