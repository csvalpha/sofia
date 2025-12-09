import Vue from 'vue/dist/vue.esm';
// eslint-disable-next-line no-unused-vars
import api from './api/axiosInstance';

const MIN_PAYMENT_AMOUNT = 21.8;

document.addEventListener('turbo:load', () => {

  const element = document.getElementById('payment-add');
  if (element !== null) {
    new Vue({
      el: element,
      data: () => {
        return {
          currentCredit: parseFloat(element.dataset.userCredit),
          paymentAmount: parseFloat(element.dataset.paymentAmount) || MIN_PAYMENT_AMOUNT
        };
      },
      computed: {
        newCredit() {
          return (this.currentCredit + parseFloat(this.paymentAmount)).toFixed(2);
        }
      },
      methods: {
        amountValid() {
          return parseFloat(this.paymentAmount) >= MIN_PAYMENT_AMOUNT;
        }
      },
    });
  }
});