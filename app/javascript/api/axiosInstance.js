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
 * Create and configure axios instance with CSRF token
 * @returns {AxiosInstance} Configured axios instance
 */
function createAxiosInstance() {
  const instance = axios.create();
  
  // Set CSRF token in default headers
  const csrfToken = getCsrfToken();
  if (csrfToken) {
    instance.defaults.headers.common['X-CSRF-Token'] = csrfToken;
  }
  
  // Set Accept header to request JSON responses
  instance.defaults.headers.common['Accept'] = 'application/json';
  
  return instance;
}

export default createAxiosInstance();
export { getCsrfToken };
