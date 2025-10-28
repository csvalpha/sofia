import Vue from 'vue/dist/vue.esm';
import UsersTable from '../components/user/UsersTable.vue';

document.addEventListener('turbo:load', () => {
  const element = document.getElementById('users-index');
  if (element !== null) {
    const manual_users = JSON.parse(element.dataset.manualUsers);
    const amber_users = JSON.parse(element.dataset.amberUsers);
    const inactive_users = JSON.parse(element.dataset.inactiveUsers);

    new Vue({
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