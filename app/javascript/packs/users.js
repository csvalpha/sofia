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
    var amber_users = JSON.parse(element.dataset.amberUsers);
    var inactive_users = JSON.parse(element.dataset.inactiveUsers);
    var show_links = JSON.parse(element.dataset.showLinks);
    new Vue({
      el: element,
      data: () => ({
        manual_users,
        amber_users,
        inactive_users,
        show_links
      }),
      components: {
        UsersTable
      },
    });
  }
});
