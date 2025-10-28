import Vue from 'vue/dist/vue.esm';

import UserInput from './components/UserInput.vue';

let vueInstance = null;

document.addEventListener('turbo:before-cache', () => {
  if (vueInstance) {
    vueInstance.$destroy();
    vueInstance = null;
  }
});

document.addEventListener('turbo:load', () => {

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