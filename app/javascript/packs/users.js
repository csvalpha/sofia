import Vue from 'vue/dist/vue.esm';
import TurbolinksAdapter from 'vue-turbolinks';
import axios from 'axios';
import BootstrapVue from 'bootstrap-vue';
import UsersTable from '../components/user/userstable.vue';

Vue.use(TurbolinksAdapter);
Vue.use(BootstrapVue);

document.addEventListener('turbolinks:load', () => {
  axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  var element = document.getElementById('users-index');
  if (element !== null) {
    var manual_users = JSON.parse(element.dataset.manualUsers);
    var amber_users = JSON.parse(element.dataset.amberUsers);
    new Vue({
      el: element,
      data: () => ({
        manual_users,
        amber_users
      }),
      components: {
        UsersTable
      },
    });
  }
});
