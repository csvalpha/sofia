import Vue from 'vue/dist/vue.esm';

import UserInput from '../components/UserInput.vue';

document.addEventListener('turbo:load', () => {

  const element = document.getElementById('new_mutation_modal');
  if (element != null) {
    new Vue({
      el: element,
      components: {
        UserInput
      }
    });
  }
});