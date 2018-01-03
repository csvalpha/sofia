import Vue from 'vue/dist/vue.esm';
import TurbolinksAdapter from 'vue-turbolinks';
import VueResource from 'vue-resource';

Vue.use(TurbolinksAdapter);
Vue.use(VueResource);

document.addEventListener('turbolinks:load', () => {
  Vue.http.headers.common['X-CSRF-TOKEN'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  var element = document.getElementById('user_tabs_content');
  if(element !== null){
    new Vue({
      el: element,
      data:  {
        selectedActivity: null
      },
      methods: {
        openModal(activity){
          $('#activity_orders_model').modal('show');
          this.selectedActivity = activity;
        }
      }
    });
  }
});
