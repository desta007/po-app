import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/api/json_converters.dart';
import '../../dashboard/data/dashboard_models.dart';

part 'report_models.freezed.dart';
part 'report_models.g.dart';

/// Baris chart `/api/reports/profit`.
@freezed
abstract class ProfitDataPoint with _$ProfitDataPoint {
  const factory ProfitDataPoint({
    required String date,
    @FlexDouble() @Default(0) double revenue,
    @FlexDouble() @Default(0) double totalCost,
    @FlexDouble() @Default(0) double profit,
    @FlexInt() @Default(0) int orderCount,
  }) = _ProfitDataPoint;

  factory ProfitDataPoint.fromJson(Map<String, dynamic> json) =>
      _$ProfitDataPointFromJson(json);
}

@freezed
abstract class ProfitSummary with _$ProfitSummary {
  const factory ProfitSummary({
    @FlexDouble() @Default(0) double totalRevenue,
    @FlexDouble() @Default(0) double totalCost,
    @FlexDouble() @Default(0) double totalProfit,
    @FlexInt() @Default(0) int totalOrders,
  }) = _ProfitSummary;

  factory ProfitSummary.fromJson(Map<String, dynamic> json) =>
      _$ProfitSummaryFromJson(json);
}

@freezed
abstract class ProfitTopProduct with _$ProfitTopProduct {
  const factory ProfitTopProduct({
    required String name,
    @FlexDouble() @Default(0) double totalQty,
    @FlexDouble() @Default(0) double revenue,
    @FlexDouble() @Default(0) double cost,
    @FlexDouble() @Default(0) double profit,
  }) = _ProfitTopProduct;

  factory ProfitTopProduct.fromJson(Map<String, dynamic> json) =>
      _$ProfitTopProductFromJson(json);
}

@freezed
abstract class ProfitReport with _$ProfitReport {
  const factory ProfitReport({
    @Default([]) List<ProfitDataPoint> chart,
    ProfitSummary? summary,
    @Default([]) List<ProfitTopProduct> topProducts,
  }) = _ProfitReport;

  factory ProfitReport.fromJson(Map<String, dynamic> json) =>
      _$ProfitReportFromJson(json);
}
