import Vue from 'vue/dist/vue.esm';
import UsersTable from './components/user/UsersTable.vue';

let vueInstance = null;

document.addEventListener('turbo:before-cache', () => {
  if (vueInstance) {
    vueInstance.$destroy();
    vueInstance = null;
  }
});

document.addEventListener('turbo:load', () => {
  const element = document.getElementById('users-index');
  if (element !== null) {
    try {
      const manual_users = JSON.parse(element.dataset.manualUsers || '[]');
      const sofia_account_users = JSON.parse(element.dataset.sofiaAccountUsers || '[]');
      const amber_users = JSON.parse(element.dataset.amberUsers || '[]');
      const not_activated_users = JSON.parse(element.dataset.notActivatedUsers || '[]');
      const deactivated_users = JSON.parse(element.dataset.deactivatedUsers || '[]');
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
