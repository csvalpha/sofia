import Vue from 'vue/dist/vue.esm';

import ProductTotals from './components/activity/ProductTotals.vue';
import Tab from 'bootstrap/js/dist/tab';

document.addEventListener('turbo:load', () => {
  const element = document.getElementById('activity');
  if (element) {
    const app = new Vue({
      el: element,
      components: {
        ProductTotals
      }
    });

    document.addEventListener('turbo:before-cache', () => {
      app.$destroy();
    }, { once: true });

    const firstTabEl = document.querySelector('#activityTabs li:first-child a');
    if (firstTabEl) {
      const firstTab = new Tab(firstTabEl);
      firstTab.show();
    }
  }
});
