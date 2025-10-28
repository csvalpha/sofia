import { Turbo } from "@hotwired/turbo-rails";
Turbo.start();

import Vue from 'vue/dist/vue.esm';
import VueResource from 'vue-resource';
import axios from 'axios';

import 'jquery';
import 'bootstrap';
import WebFont from 'webfontloader';

Vue.use(VueResource);

WebFont.load({
  google: {
    families: ['Roboto:300,400,500']
  }
});

document.addEventListener('turbo:load', () => {
  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');

  if (csrfToken) {
    Vue.http.headers.common['X-CSRF-TOKEN'] = csrfToken;
    axios.defaults.headers.common['X-CSRF-Token'] = csrfToken;
  }
});