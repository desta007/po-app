import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/async_states.dart';
import '../../purchase_orders/presentation/widgets/po_badges.dart';
import '../data/calendar_api.dart';
import '../data/calendar_models.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  String get _monthKey => DateFormat('yyyy-MM').format(_focusedDay);

  Map<DateTime, List<CalendarEvent>> _groupByDay(List<CalendarEvent> events) {
    final map = <DateTime, List<CalendarEvent>>{};
    for (final event in events) {
      final date = DateTime.tryParse(event.start);
      if (date == null) continue;
      final key = DateTime.utc(date.year, date.month, date.day);
      map.putIfAbsent(key, () => []).add(event);
    }
    return map;
  }

  Future<void> _reschedule(CalendarEvent event) async {
    final current = DateTime.tryParse(event.start) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current.isBefore(DateTime.now()) ? DateTime.now() : current,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      helpText: 'Tanggal kirim baru — ${event.props.poNumber}',
    );
    if (picked == null) return;
    try {
      await ref.read(calendarApiProvider).reschedule(event.id, picked);
      ref.invalidate(calendarEventsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '${event.props.poNumber} dijadwal ulang ke ${formatDate(picked)}.')));
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(calendarEventsProvider(_monthKey));
    final byDay = _groupByDay(eventsAsync.value ?? const []);
    final selectedKey = DateTime.utc(
        _selectedDay.year, _selectedDay.month, _selectedDay.day);
    final dayEvents = byDay[selectedKey] ?? const <CalendarEvent>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Pengiriman'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(calendarEventsProvider(_monthKey)),
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TableCalendar<CalendarEvent>(
              locale: 'id_ID',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              eventLoader: (day) =>
                  byDay[DateTime.utc(day.year, day.month, day.day)] ??
                  const [],
              startingDayOfWeek: StartingDayOfWeek.monday,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Bulan'
              },
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return null;
                  return Positioned(
                    bottom: 3,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final event in events.take(4))
                          Container(
                            width: 6,
                            height: 6,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: event.props.status.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              onDaySelected: (selected, focused) => setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              }),
              onPageChanged: (focused) =>
                  setState(() => _focusedDay = focused),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pengiriman ${formatDate(_selectedDay)} (${dayEvents.length})',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Expanded(
            child: eventsAsync.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorRetryView(
                message:
                    e is ApiException ? e.message : 'Gagal memuat kalender.',
                onRetry: () =>
                    ref.invalidate(calendarEventsProvider(_monthKey)),
              ),
              data: (_) => dayEvents.isEmpty
                  ? const EmptyView(
                      icon: Icons.event_available_outlined,
                      title: 'Tidak ada pengiriman',
                      subtitle: 'Pilih tanggal lain untuk melihat jadwal',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: dayEvents.length,
                      itemBuilder: (context, index) {
                        final event = dayEvents[index];
                        return Card(
                          margin:
                              const EdgeInsets.fromLTRB(16, 4, 16, 4),
                          child: ListTile(
                            title: Text(event.props.poNumber,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            subtitle: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(event.props.customerName),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    PoStatusBadge(
                                        status: event.props.status),
                                    const SizedBox(width: 6),
                                    PaymentStatusBadge(
                                        status:
                                            event.props.paymentStatus),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(formatRupiah(event.props.total),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                InkWell(
                                  onTap: () => _reschedule(event),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.edit_calendar,
                                        size: 20,
                                        color: AppColors.secondary),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => context.push('/po/${event.id}'),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
