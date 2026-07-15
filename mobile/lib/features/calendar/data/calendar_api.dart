import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_client.dart';
import 'calendar_models.dart';

final calendarApiProvider =
    Provider<CalendarApi>((ref) => CalendarApi(ref.watch(dioProvider)));

class CalendarApi {
  CalendarApi(this._dio);

  final Dio _dio;

  Future<List<CalendarEvent>> events({String? start, String? end}) =>
      guardApi(() async {
        final res = await _dio
            .get<Map<String, dynamic>>('/api/calendar/events', queryParameters: {
          'start': ?start,
          'end': ?end,
        });
        return (res.data!['data'] as List)
            .map((e) => CalendarEvent.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  Future<void> reschedule(String poId, DateTime deliveryDate) => guardApi(
        () => _dio.patch('/api/calendar/events/$poId/reschedule', data: {
          'delivery_date': DateFormat('yyyy-MM-dd').format(deliveryDate),
        }),
      );
}

/// Events untuk satu bulan; arg format 'yyyy-MM'.
final calendarEventsProvider =
    FutureProvider.family<List<CalendarEvent>, String>((ref, month) {
  final parts = month.split('-');
  final year = int.parse(parts[0]);
  final m = int.parse(parts[1]);
  // Ambil dengan buffer 1 minggu di kedua sisi agar grid awal/akhir bulan terisi.
  final start = DateTime(year, m, 1).subtract(const Duration(days: 7));
  final end = DateTime(year, m + 1, 0).add(const Duration(days: 7));
  final fmt = DateFormat('yyyy-MM-dd');
  return ref
      .watch(calendarApiProvider)
      .events(start: fmt.format(start), end: fmt.format(end));
});
