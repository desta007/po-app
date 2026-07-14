import apiClient from './client';

export interface FlatRate {
  name: string;
  cost: number;
}

export interface OnlineStoreConfig {
  midtrans: {
    is_enabled: boolean;
    is_production: boolean;
    client_key: string;
    server_key_set: boolean;
  };
  shipping: {
    flat_rates: FlatRate[];
    allow_pickup: boolean;
    allow_shipping_tbd: boolean;
  };
}

export interface UpdateOnlineStorePayload {
  midtrans: {
    is_enabled: boolean;
    is_production: boolean;
    client_key: string;
    /** Only send when the user typed a new key; omit/empty keeps the stored one. */
    server_key?: string;
  };
  shipping: {
    flat_rates: FlatRate[];
    allow_pickup: boolean;
    allow_shipping_tbd: boolean;
  };
}

export const onlineStoreApi = {
  get: () => apiClient.get<{ data: OnlineStoreConfig }>('/api/settings/online-store'),

  update: (data: UpdateOnlineStorePayload) =>
    apiClient.put<{ data: OnlineStoreConfig; message: string }>('/api/settings/online-store', data),

  testMidtrans: (data: { server_key?: string; is_production: boolean }) =>
    apiClient.post<{ valid: boolean; message: string }>('/api/settings/online-store/test-midtrans', data),
};
