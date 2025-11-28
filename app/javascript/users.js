import Vue from 'vue/dist/vue.esm';
import axios from 'axios';
import UsersTable from './components/user/UsersTable.vue';

let vueInstance = null;

document.addEventListener('turbo:before-cache', () => {
  if (vueInstance) {
    vueInstance.$destroy();
    vueInstance = null;
  }
});

document.addEventListener('turbo:load', () => {
  const csrfToken = document.querySelector('meta[name="csrf-token"]');
  if (csrfToken) {
    axios.defaults.headers.common['X-CSRF-Token'] = csrfToken.getAttribute('content');
  }
  const element = document.getElementById('users-index');
  if (element !== null) {
    try {
      var manual_users = JSON.parse(element.dataset.manualUsers);
      var sofia_account_users = JSON.parse(element.dataset.sofiaAccountUsers);
      var amber_users = JSON.parse(element.dataset.amberUsers);
      var not_activated_users = JSON.parse(element.dataset.notActivatedUsers);
      var deactivated_users = JSON.parse(element.dataset.deactivatedUsers);
      vueInstance = new Vue({
        el: element,
        data: () => ({
          manual_users,
          sofia_account_users,
          amber_users,
          not_activated_users,
          deactivated_users
        }),
        components: {
          UsersTable
        },
      });
    } catch (error) {
      console.error('Failed to initialize users table:', error);
    }
  }
});
