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
          id: 0,
        },
        open: false,
        allSuggestions: []
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
      created(){
          this.allSuggestions = [];
          this.$http.post('/price_lists/search.json', ).then( (response) => {
                  response.data.forEach((a) => {
                      this.allSuggestions.push(a);
                  });
              }, (error) => {
                  console.error(response);
              }
          );
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
