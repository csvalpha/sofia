import Vue from 'vue/dist/vue.esm';
import TurbolinksAdapter from 'vue-turbolinks';
import axios from 'axios';
import UsersTable from '../components/user/UsersTable.vue';

Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  var element = document.getElementById('users-index');
  if (element !== null) {
    var manual_users = JSON.parse(element.dataset.manualUsers);
    var identity_users = JSON.parse(element.dataset.identityUsers);
    var amber_users = JSON.parse(element.dataset.amberUsers);
    var not_activated_users = JSON.parse(element.dataset.notActivatedUsers);
    var deactivated_users = JSON.parse(element.dataset.deactivatedUsers);
    new Vue({
      el: element,
      data: () => ({
        manual_users,
        identity_users,
        amber_users,
        not_activated_users,
        deactivated_users
      }),
      components: {
        UsersTable
      },
    });
  }
});
