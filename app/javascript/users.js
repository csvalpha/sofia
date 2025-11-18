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
  axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
  const element = document.getElementById('users-index');
  if (element !== null) {
    const manual_users = JSON.parse(element.dataset.manualUsers);
    const amber_users = JSON.parse(element.dataset.amberUsers);
    const inactive_users = JSON.parse(element.dataset.inactiveUsers);

    vueInstance = new Vue({
      el: element,
      data: () => ({
        manual_users,
        amber_users,
        inactive_users
      }),
      components: {
        UsersTable
      },
    });
  }
});