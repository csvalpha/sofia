import Vue from 'vue/dist/vue.esm';
import TurbolinksAdapter from 'vue-turbolinks';
import VueResource from 'vue-resource';

Vue.use(TurbolinksAdapter);
Vue.use(VueResource);

document.addEventListener('turbolinks:load', () => {
  // Selects the first visible tab in the activity detail tabs
  var firstTabEl = document.querySelector('#activityTabs li:first-child a')
  var firstTab = new bootstrap.Tab(firstTabEl)
  firstTab.show()

  // Create Vue instance on the new activty modal
  Vue.http.headers.common['X-CSRF-TOKEN'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  var element = document.getElementById('new_activity_modal');
  if (element !== null) {
    var price_lists = JSON.parse(element.dataset.priceLists);
    new Vue({
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
          return this.allSuggestions.filter(value => {
            return value.name.indexOf(this.query) >= 0;
          });
        }
      },
      methods: {
        // When one of the suggestion is clicked
        suggestionClicked: function (index) {
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
