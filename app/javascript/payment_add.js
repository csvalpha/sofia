import Vue from 'vue/dist/vue.esm';
import axios from 'axios';

document.addEventListener('turbo:load', () => {
  axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  const element = document.getElementById('payment-add');
  if (element !== null) {
    const minPaymentAmount = parseFloat(element.dataset.minPaymentAmount);
    new Vue({
      el: element,
      data: () => {
        return {
          currentCredit: parseFloat(element.dataset.userCredit),
          paymentAmount: parseFloat(element.dataset.paymentAmount) || minPaymentAmount,
          minPaymentAmount: minPaymentAmount
        };
      },
      computed: {
        newCredit() {
          return (this.currentCredit + parseFloat(this.paymentAmount)).toFixed(2);
        }
      },
      methods: {
        amountValid() {
          return parseFloat(this.paymentAmount) >= this.minPaymentAmount;
        }
      },
    });
  }
});