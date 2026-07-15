import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/api/json_converters.dart';
import '../../../core/theme/app_theme.dart';
import '../../customers/data/customer_models.dart';

part 'po_models.freezed.dart';
part 'po_models.g.dart';

/// Status PO — nilai & aturan transisi sama dengan enum backend
/// (`PurchaseOrderStatus.php`).
enum PoStatus {
  draft,
  confirmed,
  @JsonValue('in_progress')
  inProgress,
  completed,
  cancelled;

  String get apiValue => switch (this) {
        inProgress => 'in_progress',
        _ => name,
      };

  String get label => switch (this) {
        draft => 'Draft',
        confirmed => 'Dikonfirmasi',
        inProgress => 'Diproses',
        completed => 'Selesai',
        cancelled => 'Dibatalkan',
      };

  Color get color => switch (this) {
        draft => AppColors.textSecondary,
        confirmed => AppColors.secondary,
        inProgress => AppColors.warning,
        completed => AppColors.accent,
        cancelled => AppColors.danger,
      };

  /// Transisi yang diizinkan backend (selain cancel via endpoint terpisah).
  List<PoStatus> get allowedTransitions => switch (this) {
        draft => [confirmed, cancelled],
        confirmed => [inProgress, cancelled],
        inProgress => [completed, cancelled],
        completed || cancelled => const [],
      };

  bool get isFinal => this == completed || this == cancelled;
}

enum PaymentStatus {
  unpaid,
  dp,
  paid;

  String get label => switch (this) {
        unpaid => 'Belum Bayar',
        dp => 'DP',
        paid => 'Lunas',
      };

  Color get color => switch (this) {
        unpaid => AppColors.danger,
        dp => AppColors.warning,
        paid => AppColors.accent,
      };
}

@freezed
abstract class PurchaseOrderItem with _$PurchaseOrderItem {
  const factory PurchaseOrderItem({
    String? id,
    String? productId,
    required String productName,
    @FlexDouble() required double quantity,
    @FlexDouble() required double unitPrice,
    @FlexDouble() @Default(0) double subtotal,
    String? notes,
    @Default(0) int sortOrder,
  }) = _PurchaseOrderItem;

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) =>
      _$PurchaseOrderItemFromJson(json);
}

@freezed
abstract class PoStatusHistory with _$PoStatusHistory {
  const factory PoStatusHistory({
    String? id,
    @JsonKey(unknownEnumValue: PoStatus.draft) PoStatus? fromStatus,
    @JsonKey(unknownEnumValue: PoStatus.draft) required PoStatus toStatus,
    String? changedBy,
    String? reason,
    String? changedAt,
  }) = _PoStatusHistory;

  factory PoStatusHistory.fromJson(Map<String, dynamic> json) =>
      _$PoStatusHistoryFromJson(json);
}

@freezed
abstract class PurchaseOrder with _$PurchaseOrder {
  const factory PurchaseOrder({
    required String id,
    required String poNumber,
    required String customerId,
    Customer? customer,
    required String orderDate,
    required String deliveryDate,
    @JsonKey(unknownEnumValue: PoStatus.draft) required PoStatus status,
    @JsonKey(unknownEnumValue: PaymentStatus.unpaid)
    required PaymentStatus paymentStatus,
    @FlexDouble() @Default(0) double dpAmount,
    @FlexDouble() @Default(0) double paidAmount,
    @FlexDouble() @Default(0) double subtotal,
    @FlexDouble() @Default(0) double discount,
    @FlexDouble() @Default(0) double tax,
    @FlexDouble() @Default(0) double shippingCost,
    @FlexDouble() @Default(0) double total,
    String? notes,
    String? paymentMethod,
    @Default([]) List<PurchaseOrderItem> items,
    @Default([]) List<PoStatusHistory> statusHistory,
    String? createdAt,
    String? updatedAt,
  }) = _PurchaseOrder;

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) =>
      _$PurchaseOrderFromJson(json);
}

/// Item pada payload create/update PO.
@freezed
abstract class PoItemInput with _$PoItemInput {
  const factory PoItemInput({
    String? productId,
    required String productName,
    required double quantity,
    required double unitPrice,
    String? notes,
  }) = _PoItemInput;

  factory PoItemInput.fromJson(Map<String, dynamic> json) =>
      _$PoItemInputFromJson(json);
}

/// Payload create/update PO (`StorePurchaseOrderRequest` /
/// `UpdatePurchaseOrderRequest` di backend).
@freezed
abstract class PoInput with _$PoInput {
  const factory PoInput({
    required String customerId,
    String? orderDate,
    required String deliveryDate,
    String? notes,
    double? discount,
    double? tax,
    double? shippingCost,
    double? dpAmount,
    required List<PoItemInput> items,
  }) = _PoInput;

  factory PoInput.fromJson(Map<String, dynamic> json) =>
      _$PoInputFromJson(json);
}

/// Filter list PO — parameter query sama dengan `POFilters` di web.
class PoFilters {
  const PoFilters({
    this.search,
    this.status,
    this.paymentStatus,
    this.customerId,
    this.dateFrom,
    this.dateTo,
  });

  final String? search;
  final PoStatus? status;
  final PaymentStatus? paymentStatus;
  final String? customerId;
  final String? dateFrom;
  final String? dateTo;

  Map<String, dynamic> toQuery() => {
        if (search != null && search!.isNotEmpty) 'search': search,
        if (status != null) 'status': status!.apiValue,
        if (paymentStatus != null) 'payment_status': paymentStatus!.name,
        if (customerId != null) 'customer_id': customerId,
        if (dateFrom != null) 'date_from': dateFrom,
        if (dateTo != null) 'date_to': dateTo,
      };

  PoFilters copyWith({
    String? search,
    PoStatus? Function()? status,
    PaymentStatus? Function()? paymentStatus,
    String? customerId,
  }) =>
      PoFilters(
        search: search ?? this.search,
        status: status != null ? status() : this.status,
        paymentStatus:
            paymentStatus != null ? paymentStatus() : this.paymentStatus,
        customerId: customerId ?? this.customerId,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

  @override
  bool operator ==(Object other) =>
      other is PoFilters &&
      other.search == search &&
      other.status == status &&
      other.paymentStatus == paymentStatus &&
      other.customerId == customerId &&
      other.dateFrom == dateFrom &&
      other.dateTo == dateTo;

  @override
  int get hashCode =>
      Object.hash(search, status, paymentStatus, customerId, dateFrom, dateTo);
}
