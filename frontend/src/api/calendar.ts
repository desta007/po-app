import apiClient from './client';
import type { CalendarEvent } from '@/types/purchase-order';

export interface CalendarFilters {
  start?: string;
  end?: string;
  status?: string;
  customer_id?: string;
}

export const calendarApi = {
  events: (filters?: CalendarFilters) =>
    apiClient.get<{ data: CalendarEvent[] }>('/api/calendar/events', { params: filters }),

  reschedule: (id: string, delivery_date: string) =>
    apiClient.patch(`/api/calendar/events/${id}/reschedule`, { delivery_date }),
};
