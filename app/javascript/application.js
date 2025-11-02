import { Turbo } from '@hotwired/turbo-rails';
Turbo.start();

import axios from 'axios';

import 'jquery';
import 'bootstrap';

import WebFont from 'webfontloader';
import '@fortawesome/fontawesome-free/css/all.css';

WebFont.load({
  google: {
    families: ['Roboto:300,400,500']
  }
});

axios.interceptors.request.use((config) => {
  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
  if (csrfToken) {
    config.headers['X-CSRF-Token'] = csrfToken;
  }
  return config;
}, (error) => {
  return Promise.reject(error);
});


document.addEventListener('turbo:load', () => {
 
});