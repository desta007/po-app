import apiClient from './client';

export const subscriptionApi = {
  status: () =>
    apiClient.get('/api/subscription/status'),

  requestUpgrade: (data?: { payment_proof_note?: string }) =>
    apiClient.post('/api/subscription/request', data),

  downloadInvoice: (id: string) =>
    apiClient.get(`/api/subscription/${id}/invoice`, { responseType: 'blob' }),
};
