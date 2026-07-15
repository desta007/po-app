// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'po_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PurchaseOrderItem _$PurchaseOrderItemFromJson(Map<String, dynamic> json) =>
    _PurchaseOrderItem(
      id: json['id'] as String?,
      productId: json['product_id'] as String?,
      productName: json['product_name'] as String,
      quantity: const FlexDouble().fromJson(json['quantity']),
      unitPrice: const FlexDouble().fromJson(json['unit_price']),
      subtotal: json['subtotal'] == null
          ? 0
          : const FlexDouble().fromJson(json['subtotal']),
      notes: json['notes'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PurchaseOrderItemToJson(_PurchaseOrderItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'product_name': instance.productName,
      'quantity': const FlexDouble().toJson(instance.quantity),
      'unit_price': const FlexDouble().toJson(instance.unitPrice),
      'subtotal': const FlexDouble().toJson(instance.subtotal),
      'notes': instance.notes,
      'sort_order': instance.sortOrder,
    };

_PoStatusHistory _$PoStatusHistoryFromJson(Map<String, dynamic> json) =>
    _PoStatusHistory(
      id: json['id'] as String?,
      fromStatus: $enumDecodeNullable(
        _$PoStatusEnumMap,
        json['from_status'],
        unknownValue: PoStatus.draft,
      ),
      toStatus: $enumDecode(
        _$PoStatusEnumMap,
        json['to_status'],
        unknownValue: PoStatus.draft,
      ),
      changedBy: json['changed_by'] as String?,
      reason: json['reason'] as String?,
      changedAt: json['changed_at'] as String?,
    );

Map<String, dynamic> _$PoStatusHistoryToJson(_PoStatusHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'from_status': _$PoStatusEnumMap[instance.fromStatus],
      'to_status': _$PoStatusEnumMap[instance.toStatus]!,
      'changed_by': instance.changedBy,
      'reason': instance.reason,
      'changed_at': instance.changedAt,
    };

const _$PoStatusEnumMap = {
  PoStatus.draft: 'draft',
  PoStatus.confirmed: 'confirmed',
  PoStatus.inProgress: 'in_progress',
  PoStatus.completed: 'completed',
  PoStatus.cancelled: 'cancelled',
};

_PurchaseOrder _$PurchaseOrderFromJson(
  Map<String, dynamic> json,
) => _PurchaseOrder(
  id: json['id'] as String,
  poNumber: json['po_number'] as String,
  customerId: json['customer_id'] as String,
  customer: json['customer'] == null
      ? null
      : Customer.fromJson(json['customer'] as Map<String, dynamic>),
  orderDate: json['order_date'] as String,
  deliveryDate: json['delivery_date'] as String,
  status: $enumDecode(
    _$PoStatusEnumMap,
    json['status'],
    unknownValue: PoStatus.draft,
  ),
  paymentStatus: $enumDecode(
    _$PaymentStatusEnumMap,
    json['payment_status'],
    unknownValue: PaymentStatus.unpaid,
  ),
  dpAmount: json['dp_amount'] == null
      ? 0
      : const FlexDouble().fromJson(json['dp_amount']),
  paidAmount: json['paid_amount'] == null
      ? 0
      : const FlexDouble().fromJson(json['paid_amount']),
  subtotal: json['subtotal'] == null
      ? 0
      : const FlexDouble().fromJson(json['subtotal']),
  discount: json['discount'] == null
      ? 0
      : const FlexDouble().fromJson(json['discount']),
  tax: json['tax'] == null ? 0 : const FlexDouble().fromJson(json['tax']),
  shippingCost: json['shipping_cost'] == null
      ? 0
      : const FlexDouble().fromJson(json['shipping_cost']),
  total: json['total'] == null ? 0 : const FlexDouble().fromJson(json['total']),
  notes: json['notes'] as String?,
  paymentMethod: json['payment_method'] as String?,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => PurchaseOrderItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  statusHistory:
      (json['status_history'] as List<dynamic>?)
          ?.map((e) => PoStatusHistory.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$PurchaseOrderToJson(_PurchaseOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'po_number': instance.poNumber,
      'customer_id': instance.customerId,
      'customer': instance.customer?.toJson(),
      'order_date': instance.orderDate,
      'delivery_date': instance.deliveryDate,
      'status': _$PoStatusEnumMap[instance.status]!,
      'payment_status': _$PaymentStatusEnumMap[instance.paymentStatus]!,
      'dp_amount': const FlexDouble().toJson(instance.dpAmount),
      'paid_amount': const FlexDouble().toJson(instance.paidAmount),
      'subtotal': const FlexDouble().toJson(instance.subtotal),
      'discount': const FlexDouble().toJson(instance.discount),
      'tax': const FlexDouble().toJson(instance.tax),
      'shipping_cost': const FlexDouble().toJson(instance.shippingCost),
      'total': const FlexDouble().toJson(instance.total),
      'notes': instance.notes,
      'payment_method': instance.paymentMethod,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'status_history': instance.statusHistory.map((e) => e.toJson()).toList(),
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

const _$PaymentStatusEnumMap = {
  PaymentStatus.unpaid: 'unpaid',
  PaymentStatus.dp: 'dp',
  PaymentStatus.paid: 'paid',
};

_PoItemInput _$PoItemInputFromJson(Map<String, dynamic> json) => _PoItemInput(
  productId: json['product_id'] as String?,
  productName: json['product_name'] as String,
  quantity: (json['quantity'] as num).toDouble(),
  unitPrice: (json['unit_price'] as num).toDouble(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$PoItemInputToJson(_PoItemInput instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'product_name': instance.productName,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'notes': instance.notes,
    };

_PoInput _$PoInputFromJson(Map<String, dynamic> json) => _PoInput(
  customerId: json['customer_id'] as String,
  orderDate: json['order_date'] as String?,
  deliveryDate: json['delivery_date'] as String,
  notes: json['notes'] as String?,
  discount: (json['discount'] as num?)?.toDouble(),
  tax: (json['tax'] as num?)?.toDouble(),
  shippingCost: (json['shipping_cost'] as num?)?.toDouble(),
  dpAmount: (json['dp_amount'] as num?)?.toDouble(),
  items: (json['items'] as List<dynamic>)
      .map((e) => PoItemInput.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PoInputToJson(_PoInput instance) => <String, dynamic>{
  'customer_id': instance.customerId,
  'order_date': instance.orderDate,
  'delivery_date': instance.deliveryDate,
  'notes': instance.notes,
  'discount': instance.discount,
  'tax': instance.tax,
  'shipping_cost': instance.shippingCost,
  'dp_amount': instance.dpAmount,
  'items': instance.items.map((e) => e.toJson()).toList(),
};
