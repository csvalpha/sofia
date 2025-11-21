import Vue from 'vue/dist/vue.esm';
import VueResource from 'vue-resource';

import UserInput from './components/UserInput.vue';
import moment from 'moment';

Vue.use(VueResource);
let vueInstance = null;

document.addEventListener('turbo:before-cache', () => {
  if (vueInstance) {
    vueInstance.$destroy();
    vueInstance = null;
  }
});

document.addEventListener('turbo:load', () => {
  Vue.http.headers.common['X-CSRF-TOKEN'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
  const element = document.getElementById('new_invoice_modal');
  if (element != null) {
    const activities = JSON.parse(element.dataset.activities);
    vueInstance = new Vue({
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
        dropdownOpened() {
          return this.open === true;
        },
        suggestions() {
          return this.allSuggestions.filter(value => {
            return value.title.toLowerCase().indexOf(this.query.toLowerCase()) >= 0;
          });
        }
      },
      methods: {
        suggestionClicked: function (index) {
          this.selectedSuggestion = this.suggestions[index];
          this.query = this.selectedSuggestion.title;
          this.open = false;
        },

        openSuggestions: function () {
          this.open = true;
        },
        formatDate(time) {
          return moment(time).format('DD-MM-YY HH:mm');
        },
        addRow() {
          const invoiceRowContainer = document.getElementById('invoice_row');
          const lastRow = invoiceRowContainer.lastElementChild;
          const newRow = lastRow.cloneNode(true);

          invoiceRowContainer.appendChild(newRow);
          Array.from(newRow.children).forEach((fieldWrapper) => {
            let newIndex = -1;
            if (fieldWrapper.firstElementChild) {
              const nameAttr = fieldWrapper.firstElementChild.name;
              if (nameAttr) {
                if (newIndex === -1) {
                  const match = nameAttr.match(/invoice\[rows_attributes\]\[(\d+)\]/);
                  if (match && match[1]) {
                    newIndex = Number(match[1]) + 1;
                  }
                }
                if (newIndex !== -1) {
                  fieldWrapper.firstElementChild.name = nameAttr.replace(/\[\d+\]/g, '[' + newIndex + ']');
                  fieldWrapper.firstElementChild.value = '';
                }
              }
            }
          });
        }
      }
    });
  }
});