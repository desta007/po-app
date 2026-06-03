import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { calendarApi } from '@/api/calendar';
import { PageHeader } from '@/components/layout/page-header';
import FullCalendar from '@fullcalendar/react';
import dayGridPlugin from '@fullcalendar/daygrid';
import listPlugin from '@fullcalendar/list';
import interactionPlugin from '@fullcalendar/interaction';
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { Plus } from 'lucide-react';
import { ROUTES } from '@/lib/constants';
import { toast } from 'sonner';

export default function CalendarPage() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [dateRange, setDateRange] = useState({ start: '', end: '' });

  const { data } = useQuery({
    queryKey: ['calendar', dateRange],
    queryFn: () => calendarApi.events(dateRange),
    enabled: !!dateRange.start,
  });

  const reschedule = useMutation({
    mutationFn: ({ id, date }: { id: string; date: string }) => calendarApi.reschedule(id, date),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ['calendar'] }); toast.success('Tanggal pengiriman diperbarui.'); },
  });

  const events: any[] = (data as any)?.data?.data || (data as any)?.data || [];

  return (
    <div>
      <PageHeader
        title="Kalender"
        description="Jadwal pengiriman pesanan"
        actions={<Button onClick={() => navigate(ROUTES.PO_CREATE)}><Plus size={15} /> PO Baru</Button>}
      />

      <div className="bg-white rounded-[10px] border border-gray-200 p-5 calendar-wrapper">
        <style>{`
          .calendar-wrapper .fc {
            font-family: 'Plus Jakarta Sans', sans-serif;
          }
          .calendar-wrapper .fc-toolbar-title {
            font-size: 18px !important;
            font-weight: 700 !important;
          }
          .calendar-wrapper .fc-button {
            background: white !important;
            border: 1px solid #D4D4D4 !important;
            color: #404040 !important;
            font-size: 12px !important;
            font-weight: 600 !important;
            padding: 6px 12px !important;
            border-radius: 6px !important;
            text-transform: capitalize !important;
          }
          .calendar-wrapper .fc-button:hover {
            background: #F5F5F5 !important;
          }
          .calendar-wrapper .fc-button-active {
            background: white !important;
            color: #1F4E79 !important;
            box-shadow: 0 1px 2px rgba(0,0,0,0.04) !important;
          }
          .calendar-wrapper .fc-button-primary:not(:disabled).fc-button-active {
            background: #1F4E79 !important;
            color: white !important;
            border-color: #1F4E79 !important;
          }
          .calendar-wrapper .fc-col-header-cell {
            background: #FAFAFA;
            border-bottom: 1px solid #E5E5E5;
            padding: 8px;
            font-size: 11px;
            font-weight: 700;
            color: #737373;
            text-transform: uppercase;
            letter-spacing: 0.05em;
          }
          .calendar-wrapper .fc-daygrid-day-number {
            font-size: 12px;
            font-weight: 600;
            padding: 6px;
          }
          .calendar-wrapper .fc-day-today {
            background: #EBF2F9 !important;
          }
          .calendar-wrapper .fc-day-today .fc-daygrid-day-number {
            color: #1F4E79;
            font-weight: 800;
          }
          .calendar-wrapper .fc-event {
            font-size: 10px !important;
            padding: 4px !important;
            border-radius: 4px !important;
            border: none !important;
          }
          .calendar-wrapper .fc-event-main {
            white-space: normal !important;
            line-height: 1.2;
          }
          .calendar-wrapper .fc-daygrid-day {
            min-height: 110px;
            cursor: pointer;
          }
          .calendar-wrapper .fc-daygrid-day:hover {
            background: #FAFAFA;
          }
          .calendar-wrapper .fc-more-link {
            font-size: 10px;
            color: #737373;
            font-weight: 600;
          }
          .calendar-wrapper .fc th,
          .calendar-wrapper .fc td {
            border-color: #F5F5F5;
          }
          .calendar-wrapper .fc .fc-scrollgrid {
            border-color: #E5E5E5;
          }
        `}</style>
        <FullCalendar
          plugins={[dayGridPlugin, listPlugin, interactionPlugin]}
          initialView="dayGridMonth"
          locale="id"
          headerToolbar={{
            left: 'prev,next today',
            center: 'title',
            right: 'dayGridMonth,listWeek',
          }}
          events={events}
          editable
          eventContent={(info) => {
            const customerName = info.event.extendedProps.customer_name;
            const items = info.event.extendedProps.items || [];
            return (
              <div className="flex flex-col gap-0.5 overflow-hidden w-full text-white">
                <div className="font-bold truncate">{customerName}</div>
                {items.map((item: any, idx: number) => (
                  <div key={idx} className="text-[9px] opacity-90 truncate">
                    • {item.product_name} ({item.quantity})
                  </div>
                ))}
              </div>
            );
          }}
          eventClick={(info) => navigate(ROUTES.PO_DETAIL(info.event.id))}
          eventDrop={(info) => {
            const newDate = info.event.startStr;
            if (confirm(`Pindahkan ke ${newDate}?`)) {
              reschedule.mutate({ id: info.event.id, date: newDate });
            } else {
              info.revert();
            }
          }}
          datesSet={(arg) => setDateRange({ start: arg.startStr.slice(0, 10), end: arg.endStr.slice(0, 10) })}
          height="auto"
          dayMaxEvents={3}
          buttonText={{ today: 'Hari ini', month: 'Bulan', list: 'Daftar' }}
        />
      </div>

      <div className="mt-4 bg-primary-50 border border-primary-100 rounded-[10px] p-3 flex items-start gap-2.5 text-[13px] text-primary">
        <span className="text-lg">ℹ️</span>
        <div><strong>Tip:</strong> Drag-and-drop event ke tanggal lain untuk reschedule. Klik event untuk lihat detail.</div>
      </div>
    </div>
  );
}
