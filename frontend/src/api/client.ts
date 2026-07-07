import axios, { AxiosError, InternalAxiosRequestConfig } from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || '';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

// --- Token Refresh Logic ---
let isRefreshing = false;
let failedQueue: Array<{
  resolve: (token: string) => void;
  reject: (error: unknown) => void;
}> = [];

const processQueue = (error: unknown, token: string | null = null) => {
  failedQueue.forEach(({ resolve, reject }) => {
    if (token) {
      resolve(token);
    } else {
      reject(error);
    }
  });
  failedQueue = [];
};

// Interceptor: attach Bearer token from localStorage to every request
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('auth_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

apiClient.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    const originalRequest = error.config as InternalAxiosRequestConfig & { _retry?: boolean };

    // If 401 and not already retrying, attempt token refresh
    if (error.response?.status === 401 && !originalRequest._retry) {
      const authPaths = ['/login', '/register', '/lupa-password', '/reset-password'];
      if (authPaths.some((p) => window.location.pathname.startsWith(p))) {
        return Promise.reject(error);
      }

      // If refresh endpoint itself fails, don't retry
      if (originalRequest.url?.includes('/auth/refresh')) {
        localStorage.removeItem('auth_token');
        window.location.href = '/';
        return Promise.reject(error);
      }

      if (isRefreshing) {
        // Queue requests while refresh is in progress
        return new Promise((resolve, reject) => {
          failedQueue.push({
            resolve: (token: string) => {
              originalRequest.headers.Authorization = `Bearer ${token}`;
              resolve(apiClient(originalRequest));
            },
            reject,
          });
        });
      }

      originalRequest._retry = true;
      isRefreshing = true;

      try {
        const token = localStorage.getItem('auth_token');
        const { data } = await axios.post(
          `${API_BASE_URL}/api/auth/refresh`,
          {},
          { headers: { Authorization: `Bearer ${token}` } }
        );

        const newToken = data.token;
        localStorage.setItem('auth_token', newToken);
        originalRequest.headers.Authorization = `Bearer ${newToken}`;
        processQueue(null, newToken);

        return apiClient(originalRequest);
      } catch (refreshError) {
        processQueue(refreshError, null);
        localStorage.removeItem('auth_token');
        window.location.href = '/';
        return Promise.reject(refreshError);
      } finally {
        isRefreshing = false;
      }
    }

    // Handle 403 upgrade_required
    if (error.response?.status === 403) {
      const data = error.response.data as Record<string, unknown>;
      if (data?.upgrade_required) {
        window.dispatchEvent(new CustomEvent('upgrade-required', {
          detail: {
            message: data.message as string,
            resource: data.resource as string,
            usage: data.usage as { current: number; limit: number } | undefined,
          },
        }));
      }
    }

    // Non-401 errors or already retried
    if (error.response?.status === 401) {
      localStorage.removeItem('auth_token');
      const authPaths = ['/login', '/register', '/lupa-password', '/reset-password'];
      if (!authPaths.some((p) => window.location.pathname.startsWith(p))) {
        window.location.href = '/';
      }
    }

    return Promise.reject(error);
  }
);

export default apiClient;
