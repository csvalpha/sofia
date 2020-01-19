import Vue from 'vue/dist/vue.esm';
import TurbolinksAdapter from 'vue-turbolinks';
import axios from 'axios';

Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  var element = document.getElementById('payment-add');
  if (element !== null) {
    new Vue({
      el: element,
      data: () => {
        return {
          currentCredit: parseFloat(element.dataset.userCredit),
          paymentAmount: parseFloat(element.dataset.paymentAmount) || 20
        };
      },
      computed: {
        newCredit() {
          return (this.currentCredit + parseFloat(this.paymentAmount)).toFixed(2);
        }
      },
      methods: {
        amountValid() {
          return parseFloat(this.paymentAmount) >= 20;
        }
      },
    });
  }
});
