import Vue from 'vue/dist/vue.esm';
import TurbolinksAdapter from 'vue-turbolinks';
import VueResource from 'vue-resource';

import UserInput from '../components/userinput.vue';
import moment from 'moment';

Vue.use(TurbolinksAdapter);
Vue.use(VueResource);

document.addEventListener('turbolinks:load', () => {
  Vue.http.headers.common['X-CSRF-TOKEN'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  var element = document.getElementById('new_invoice_modal');
  if (element != null) {
    var activities = JSON.parse(element.dataset.activities);
    new Vue({
      el: element,
      components: {
        UserInput
      },
      data: {
        query: '',
        selectedSuggestion: {
          id: 0,
        },
        open: false,
        allSuggestions: activities
      },
      computed: {
        dropdownOpened () {
          return this.open === true;
        },
        suggestions () {
          return this.allSuggestions.filter(value => {
            return value.title.indexOf(this.query) >= 0;
          });
        }
      },
      methods: {
        // When one of the suggestion is clicked
        suggestionClicked: function (index) {
          this.selectedSuggestion = this.suggestions[index];
          this.query = this.selectedSuggestion.title;
          this.open = false;
        },

        openSuggestions: function() {
          this.open = true;
        },
        formatDate(time) {
          return moment(time).format('DD-MM-YY HH:mm');
        },
        addRow() {
          document.getElementById('invoice_rows').appendChild(document.getElementById('invoice_row').cloneNode(true));
        }
      }
    });
  }
});
