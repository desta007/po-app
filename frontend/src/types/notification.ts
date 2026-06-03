export interface Notification {
  id: string;
  title: string;
  message: string;
  channel: 'in_app' | 'email' | 'whatsapp';
  po_id: string | null;
  read_at: string | null;
  created_at: string;
}
