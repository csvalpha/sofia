import Vue from 'vue/dist/vue.esm';
import TurbolinksAdapter from 'vue-turbolinks';
import axios from 'axios';
import BootstrapVue from 'bootstrap-vue';

import OrderHistory from '../components/orderhistory.vue';

Vue.use(TurbolinksAdapter);
Vue.use(BootstrapVue);

document.addEventListener('turbolinks:load', () => {
  axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  var element = document.getElementById('user-container');
  if (element !== null) {
    var user = JSON.parse(element.dataset.user);
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
