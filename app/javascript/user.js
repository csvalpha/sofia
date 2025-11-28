import Vue from 'vue/dist/vue.esm';
import axios from 'axios';

import OrderHistory from './components/user/OrderHistory.vue';


document.addEventListener('turbo:load', () => {
  axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  const element = document.getElementById('user-container');
  if (element !== null) {
    const user = JSON.parse(element.dataset.user);
    new Vue({
      el: element,
      data: () => ({
        user,
      }),
      components: {
        OrderHistory
      }
    });
  }
});
