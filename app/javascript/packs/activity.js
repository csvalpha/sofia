import Vue from 'vue/dist/vue.esm';
import TurbolinksAdapter from 'vue-turbolinks';
import VueResource from 'vue-resource';

import ProductTotals from '../components/activity/ProductTotals.vue';

Vue.use(TurbolinksAdapter);
Vue.use(VueResource);

document.addEventListener('turbolinks:load', () => {
  Vue.http.headers.common['X-CSRF-TOKEN'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  var element = document.getElementById('activity');
  if (element !== null) {
    // Create a Vue instance for the ProductTotals component
    new Vue({
      el: element,
      components: {
        ProductTotals
      }
    });

    // Selects the first visible tab in the activity detail tabs
    var firstTabEl = document.querySelector('#activityTabs li:first-child a')
    var firstTab = new bootstrap.Tab(firstTabEl)
    firstTab.show()
  }
});
