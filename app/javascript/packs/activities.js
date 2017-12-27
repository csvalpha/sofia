import Vue from 'vue/dist/vue.esm';
import TurbolinksAdapter from 'vue-turbolinks';
import VueResource from 'vue-resource';

Vue.use(TurbolinksAdapter);
Vue.use(VueResource);

document.addEventListener('turbolinks:load', () => {
  Vue.http.headers.common['X-CSRF-TOKEN'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  var element = document.getElementById('edit_activity_modal');
  if (element !== null) {
    var price_lists = JSON.parse(element.dataset.priceLists);
    var vueActivities = new Vue({
      el: element,
      data: {
        query: '',
        selectedSuggestion: {
          id: 0,
        },
        open: false,
        allSuggestions: price_lists
      },
      computed: {
        dropdownOpened () {
          return this.open === true;
        },
        suggestions () {
          const substrRegex = new RegExp(this.query, 'i');
          return this.allSuggestions.filter(value => {
            return substrRegex.test(value.name);
          });
        }
      },
      methods: {
        // When one of the suggestion is clicked
        suggestionClicked: function(index) {
          this.selectedSuggestion = this.suggestions[index];
          this.query = this.selectedSuggestion.name;
          this.open = false;
        },

        openSuggestions: function() {
          this.open = true;
        },
      }
    });
  }
});
