import Vue from 'vue/dist/vue.esm';
import VueResource from 'vue-resource';

import ProductTotals from './components/activity/ProductTotals.vue';

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
