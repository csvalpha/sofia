import axios from 'axios';

/**
 * Get CSRF token from meta tag
 * @returns {string} CSRF token
 */
function getCsrfToken() {
  const token = document.querySelector('meta[name="csrf-token"]');
  return token ? token.getAttribute('content') : '';
}

/**
 * Create and configure axios instance.
 * CSRF is injected via a request interceptor so the latest token is used.
 * @returns {AxiosInstance} Configured axios instance
 */
function createAxiosInstance() {
  const instance = axios.create();

  // Always ask for JSON responses
  instance.defaults.headers.common['Accept'] = 'application/json';

  instance.interceptors.request.use((config) => {
    const csrfToken = getCsrfToken();
    if (csrfToken) {
      config.headers['X-CSRF-Token'] = csrfToken;
    }
    return config;
  });

  return instance;
}

const axiosInstance = createAxiosInstance();

export default axiosInstance;
export { getCsrfToken, axiosInstance };
