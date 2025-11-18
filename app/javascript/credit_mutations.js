import Vue from 'vue/dist/vue.esm';
import VueResource from 'vue-resource';

import UserInput from './components/UserInput.vue';

Vue.use(VueResource);

let vueInstance = null;

document.addEventListener('turbo:before-cache', () => {
  if (vueInstance) {
    vueInstance.$destroy();
    vueInstance = null;
  }
});

document.addEventListener('turbo:load', () => {
  Vue.http.headers.common['X-CSRF-TOKEN'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  const element = document.getElementById('new_mutation_modal');
  if (element != null) {
    vueInstance = new Vue({
      el: element,
      components: {
        UserInput
      }
    });
  }
});