import Vue from 'vue/dist/vue.esm';

import ProductTotals from './components/activity/ProductTotals.vue';

document.addEventListener('turbo:load', () => {
  const element = document.getElementById('activity');
  if (element) {
    new Vue({
      el: element,
      components: {
        ProductTotals
      }
    });

    const firstTabEl = document.querySelector('#activityTabs li:first-child a');
    if (firstTabEl) {
      /* eslint-disable no-undef */
      const firstTab = new bootstrap.Tab(firstTabEl);
      firstTab.show();
    }
  }
});
