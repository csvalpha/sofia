import Vue from 'vue/dist/vue.esm';

const MIN_PAYMENT_AMOUNT = 20;

document.addEventListener('turbo:load', () => {
  const element = document.getElementById('payment-add');
  if (element !== null) {
    new Vue({
      el: element,
      data: () => {
        return {
          currentCredit: parseFloat(element.dataset.userCredit) || 0,
          paymentAmount: parseFloat(element.dataset.paymentAmount) || MIN_PAYMENT_AMOUNT
        };
      },
      computed: {
        newCredit() {
          return (this.currentCredit + this.paymentAmount).toFixed(2);
        }
      },
      methods: {
        amountValid() {
          return this.paymentAmount >= MIN_PAYMENT_AMOUNT;
        }
      },
    });
  }
});