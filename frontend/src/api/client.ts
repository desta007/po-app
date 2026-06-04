import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || '';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  withCredentials: true,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

let csrfTokenFetched = false;

// CSRF token handling for Laravel Sanctum
apiClient.interceptors.request.use(async (config) => {
  if (['post', 'put', 'patch', 'delete'].includes(config.method || '') && !csrfTokenFetched) {
    await axios.get(`${API_BASE_URL}/sanctum/csrf-cookie`, {
      withCredentials: true,
    });
    csrfTokenFetched = true;
  }
  return config;
});

apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Don't redirect if already on auth pages
      const authPaths = ['/login', '/register', '/lupa-password', '/reset-password'];
      if (!authPaths.some((p) => window.location.pathname.startsWith(p))) {
        window.location.href = '/login';
      }
    }
    if (error.response?.status === 419) {
      // CSRF token expired, reset and retry
      csrfTokenFetched = false;
    }
    return Promise.reject(error);
  }
);

export default apiClient;
