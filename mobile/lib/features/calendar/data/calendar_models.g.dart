// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CalendarEvent _$CalendarEventFromJson(Map<String, dynamic> json) =>
    _CalendarEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      start: json['start'] as String,
      props: CalendarEventProps.fromJson(
        json['extendedProps'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$CalendarEventToJson(_CalendarEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'start': instance.start,
      'extendedProps': instance.props.toJson(),
    };

_CalendarEventProps _$CalendarEventPropsFromJson(Map<String, dynamic> json) =>
    _CalendarEventProps(
      poNumber: json['po_number'] as String,
      customerName: json['customer_name'] as String,
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
      total: json['total'] == null
          ? 0
          : const FlexDouble().fromJson(json['total']),
    );

Map<String, dynamic> _$CalendarEventPropsToJson(_CalendarEventProps instance) =>
    <String, dynamic>{
      'po_number': instance.poNumber,
      'customer_name': instance.customerName,
      'status': _$PoStatusEnumMap[instance.status]!,
      'payment_status': _$PaymentStatusEnumMap[instance.paymentStatus]!,
      'total': const FlexDouble().toJson(instance.total),
    };

const _$PoStatusEnumMap = {
  PoStatus.draft: 'draft',
  PoStatus.confirmed: 'confirmed',
  PoStatus.inProgress: 'in_progress',
  PoStatus.completed: 'completed',
  PoStatus.cancelled: 'cancelled',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.unpaid: 'unpaid',
  PaymentStatus.dp: 'dp',
  PaymentStatus.paid: 'paid',
};
