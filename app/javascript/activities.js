import Vue from 'vue/dist/vue.esm';
import VueResource from 'vue-resource';

Vue.use(VueResource);

document.addEventListener('turbo:load', () => {
  Vue.http.headers.common['X-CSRF-TOKEN'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
  const element = document.getElementById('new_activity_modal');
  if (element) {
    const priceLists = JSON.parse(element.dataset.priceLists);

    new Vue({
      el: element,
      data: {
        query: '',
        selectedSuggestion: {
          id: 0,
        },
        open: false,
        allSuggestions: priceLists
      },
      computed: {
        dropdownOpened () {
          return this.open === true;
        },
        suggestions () {
          return this.allSuggestions.filter(value => {
            return value.name.toLowerCase().indexOf(this.query.toLowerCase()) >= 0;
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