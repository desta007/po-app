export type WaitlistStatus = 'waiting' | 'called' | 'seated' | 'cancelled' | 'no_show';

export interface WaitlistEntry {
  id: string;
  queue_number: number;
  guest_name: string;
  party_size: number;
  phone: string | null;
  status: WaitlistStatus;
  table_id: string | null;
  table_label: string | null;
  notes: string | null;
  called_at: string | null;
  call_count: number;
  seated_at: string | null;
  created_at: string;
  table?: { id: string; label: string } | null;
}

export interface WaitlistStats {
  waiting: number;
  called: number;
  seated: number;
  cancelled: number;
  no_show: number;
}

export type RestoTableStatus = 'available' | 'occupied';

export interface RestoTable {
  id: string;
  label: string;
  capacity: number;
  status: RestoTableStatus;
  is_active: boolean;
  sort_order: number;
}
