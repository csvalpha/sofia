import Vue from 'vue/dist/vue.esm';

import ProductTotals from './components/activity/ProductTotals.vue';

let vueInstance = null;

document.addEventListener('turbo:before-cache', () => {
  if (vueInstance) {
    vueInstance.$destroy();
    vueInstance = null;
  }
});

document.addEventListener('turbo:load', () => {
  const element = document.getElementById('activity');
  if (element) {
    vueInstance = new Vue({
      el: element,
      components: {
        ProductTotals
      }
    });
  }
});
