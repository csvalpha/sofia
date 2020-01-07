import Vue from 'vue/dist/vue.esm';
import TurbolinksAdapter from 'vue-turbolinks';
import axios from 'axios';
import BootstrapVue from 'bootstrap-vue';

Vue.use(TurbolinksAdapter);
Vue.use(BootstrapVue);

document.addEventListener('turbolinks:load', () => {
  axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  var element = document.getElementById('users-index');
  if (element !== null) {
    var users = JSON.parse(element.dataset.users);
    new Vue({
      el: element,
      data: () => {
        return {
          users: users,
          fields: [
            {
              key: 'id',
              label: '#',
              sortable: true,
              isRowHeader: true
            },
            {
              key: 'name',
              label: 'Naam',
              sortable: true
            },
            {
              key: 'credit',
              label: 'Saldo',
              sortable: true,
              tdClass: (value) => {
                return value <= 0 ? 'text-danger' : '';
              },
              formatter: (value) => `€ ${parseFloat(value).toFixed(2)}`,
            }
          ]
        };
      },
    });
  }
});
