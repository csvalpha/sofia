import Vue from 'vue/dist/vue.esm';
import TurbolinksAdapter from 'vue-turbolinks';
import VueResource from 'vue-resource';

Vue.use(TurbolinksAdapter);
Vue.use(VueResource);

document.addEventListener('turbolinks:load', () => {
  Vue.http.headers.common['X-CSRF-TOKEN'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  var element = document.getElementById('activities_modal');
  if (element != null) {
    var vueActivities = new Vue({
      el: element,
      data: {
        query: '',
        selectedSuggestion: {
          id: 0
        },
        open: false,
        suggestions: [],
        suggestionsUpdatedAt: null
      },
      computed: {
        dropdownOpened () {
          return this.query !== '' &&
                 this.suggestions.length !== 0 &&
                 this.open === true;
        }
      },
      methods: {
        updateValue: function() {
          if ((new Date() - this.suggestionsUpdatedAt) > 150) {
            this.updateSuggestions();
          } else if (this.open === false) {
            this.open = true;
          }
        },

        // When one of the suggestion is clicked
        suggestionClicked: function(index) {
          this.selectedSuggestion = this.suggestions[index];
          this.query = this.selectedSuggestion.name;
          this.open = false;
        },

        updateSuggestions: function() {
          this.suggestions = [];
          if (this.query.length < 1) {
            return;
          }
          this.$http.post('/price_lists/search.json', { query: this.query }).then( (response) => {
              response.data.forEach((a) => {
                this.suggestions.push(a);
              });
              this.updateValue();
            }, (error) => {
              console.error(response);
            }
          );
          this.suggestionsUpdatedAt = new Date();
        },
      }
    });
  }
});
