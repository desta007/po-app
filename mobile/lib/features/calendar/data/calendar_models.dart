import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/api/json_converters.dart';
import '../../purchase_orders/data/po_models.dart';

part 'calendar_models.freezed.dart';
part 'calendar_models.g.dart';

/// Event kalender dari `GET /api/calendar/events`
/// (bentuk mengikuti FullCalendar di web).
@freezed
abstract class CalendarEvent with _$CalendarEvent {
  const factory CalendarEvent({
    required String id,
    required String title,
    required String start,
    @JsonKey(name: 'extendedProps') required CalendarEventProps props,
  }) = _CalendarEvent;

  factory CalendarEvent.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventFromJson(json);
}

@freezed
abstract class CalendarEventProps with _$CalendarEventProps {
  const factory CalendarEventProps({
    required String poNumber,
    required String customerName,
    @JsonKey(unknownEnumValue: PoStatus.draft) required PoStatus status,
    @JsonKey(unknownEnumValue: PaymentStatus.unpaid)
    required PaymentStatus paymentStatus,
    @FlexDouble() @Default(0) double total,
  }) = _CalendarEventProps;

  factory CalendarEventProps.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventPropsFromJson(json);
}
