import Vue from 'vue/dist/vue.esm';
import TurbolinksAdapter from 'vue-turbolinks';
import axios from 'axios';
import BootstrapVue from 'bootstrap-vue';

import OrderHistory from '../orderscreen/orderhistory.vue';

Vue.use(TurbolinksAdapter);
Vue.use(BootstrapVue);

document.addEventListener('turbolinks:load', () => {
  axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  var element = document.getElementById('user-history-table');
  if (element !== null) {
    var user = JSON.parse(element.dataset.user);
    new Vue({
      el: element,
      data: () => {
        return {
          user: user
        };
      },
      components: {
        OrderHistory
      }
    });
  }
});
