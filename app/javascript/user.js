import Vue from 'vue/dist/vue.esm';
import api from './api/axiosInstance';

import OrderHistory from './components/user/OrderHistory.vue';


document.addEventListener('turbo:load', () => {

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
